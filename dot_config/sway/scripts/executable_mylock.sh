#!/usr/bin/env bash
# https://gitlab.com/wef/dotfiles/-/blob/master/bin/mylock
# shellcheck disable=SC2034
TIME_STAMP="20221026.170156"

# Copyright 2021 Bob Hepple < bob dot hepple at gmail dot com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

PROG=$( basename "$0" )

# config file:
CFG_FILE=${XDG_CONFIG_DIR:-$HOME/.config}/$PROG/config

# shellcheck disable=SC2016
DEFAULT_CONFIG='
# time between events (secs)
TIMEOUT=600
# customise this to wherever you have a nice collection of background images:
IMAGE_COLLECTION="${XDG_PICTURES_DIR:-$HOME/Pictures}"
# if set, download a random image every time:
DOWNLOAD_RANDOM_IMAGE=""
# if set, delete the downloaded image (does not affect images in the $IMAGE_COLLECTION)
DELETE_DOWNLOADED_IMAGE=""
# URL for random screensaver images, if $DOWNLOAD_RANDOM_IMAGE is set:
IMAGE_URL="https://unsplash.it/1920/1080/?random"
# where the sway keybindings are kept (default is ~/.config/sway/config):
BINDINGS_FILE=${XDG_CONFIG_DIR:-$HOME/.config}/sway/config
# default is to use swaylock; gtklock is also supported
LOCK_PROGRAM="swaylock"
# or LOCK_PROGRAM="gtklock"
#    GTKLOCK_CONFIG_DIR=${XDG_CONFIG_DIR:-$HOME/.config}/gtklock
# set this if you want to run nwg-wrapper at lock-time:
NWG_WRAPPER=""
'

eval "$DEFAULT_CONFIG"

MODES="\
blank:       until <Enter> key; no change to auto-blanking/lock/suspend
lock-now:    no change to auto-blanking/lock/suspend
safe:        auto-blanking, auto-lock & auto-suspend
at-home:     auto-blanking but no auto-lock or auto-suspend
download:    auto-blanking and auto-lock but no auto-suspend
desktop:     same as download-mode
movie:       no auto-blanking, auto-lock or auto-suspend
(resume):    wake up from blanking/locking (internal use only)
"

usage() {
    echo "Usage: $PROG [OPTIONS] [seconds] [mode]

Set up swayidle with automatic screen blanking, lock and/or suspend
after an idle period according to your desired 'mode':

safe          should be the default at startup in the sway config.
at-home       if you're in a safe environment and don't need auto-locking eg. at home
download      while downloading - no suspend
desktop       is a synonym for download-mode
movie-mode    eg at home watching a movie - no suspend nor locking nor blanking

Includes locking of keepassxc if running.

You can put default settings in the config file $CFG_FILE

OPTIONS:

-c|--config <file> : config file

-d|--delete-downloaded-image:
                     delete the downloaded image after use
                     Or put DELETE_DOWNLOADED_IMAGE=true in the config file.

-i|--image <image> : use a specific screensaver image
                     Or put IMAGE=<filename> in the config file.

-q|--quiet:          don't popup confirmation dialog
                     Or put QUIET=true in the config file.

-n|--no-notify:      don't send notification
                     Or put NOTIFY=\"\" in the config file.

-r|--download-random-image:
                     download a random screensaver image from unsplash.it
                     Images are stored in \$IMAGE_COLLECTION (usually ~/Pictures) 
                     Or put DOWNLOAD_RANDOM_IMAGE=true in the config file.

If neither -i|--image or -r|--download-random-image is given then a random image
from \$IMAGE_COLLECTION is used.

'seconds' is the time before an idle event is triggered (default 600 = 10m)
Or put TIMEOUT=<seconds> in the config file.

'mode' is one of:
$MODES

If no argument is given then a wofi dialog pops up to select one of
the above modes.

In all modes (except movie-mode), the screen is
blanked after the first timeout. Locking, if enabled, happens on the
next timeout and then suspend, if enabled. For safety after a suspend,
safe-mode is enabled and the screen is locked.

Dependencies: wofi, swayidle, swaylock or gtklock, wget for downloading images.

Optional dependency is nwg-wrapper at
https://github.com/nwg-piotr/nwg-wrapper

Optional dependency is keepassxc.

I suggest the following key bindings and startup for sway's config file:

# this first one pops up the dialog to select the mode:
bindsym  \$mod+l                exec $PROG  
bindsym  Shift+\$mod+l          exec $PROG at-home-mode
bindsym  Control+\$mod+l        exec $PROG safe-mode
bindsym  Control+Shift+\$mod+l  exec $PROG lock-now
...

It is recommended to have the following in your sway config to start
swayidle with safe defaults:

exec $PROG safe-mode
or
exec $PROG desktop

Sample config file:
$DEFAULT_CONFIG"
}

# defaults
DOWNLOAD_RANDOM_IMAGE=""
DELETE_DOWNLOADED_IMAGE=""
IMAGE=""
SELF=$0
QUIET=
NOTIFY="set"

# shellcheck disable=SC1090
[[ -r "$CFG_FILE" ]] && source "$CFG_FILE"

# process options:
TEMP=$( getopt --options c:dhi:qnr --longoptions config:,delete-downloaded-image,help,image:,quiet,no-notify,random -- "$@" ) || exit 1
eval set -- "$TEMP"

for i in "$@"; do
    case $i in
        -c|--config)
            # load settings from config file:
            CFG_FILE="$2"
            shift 2
            ;;

      -r|--random) DOWNLOAD_RANDOM_IMAGE="true"; shift;;
      -d|--delete-downloaded-image) DELETE_DOWNLOADED_IMAGE="true"; shift;;
      -i|--image)
          IMAGE="$2"
          shift 2
          [[ -r $IMAGE ]] || {
              echo "$PROG: no such image $IMAGE" >&2
              exit 1
          }
          ;;
      -q|--quiet) QUIET="set"; shift ;;
      -n|--no-notify) NOTIFY="" ;;
      -h|--help) usage; exit 0;;
    --) shift; break;;
  esac
done

type "$PROG" &>/dev/null || PATH+=":$( dirname "$0" )"

get_current_idle() {
    # shellcheck disable=SC2009
    IDLE=$( ps -ef | grep '[s]wayidle' )
            
    IDLE=$( echo "$IDLE" | sed "s/^.*swayidle //; s/timeout/\n&/g; s/before-sleep/\n&/g; s/after-resume/\n&/g" )
    MASK=0
    if echo "$IDLE" | grep -q '^timeout .* lock-now'; then
        LOCKING="on"
        MASK=$(( MASK + 100 ))
    else
        LOCKING="off"
    fi
    if echo "$IDLE" | grep -q '^timeout .* suspend'; then
        SUSPEND="on"
        MASK=$(( MASK + 10 ))
    else
        SUSPEND="off"
    fi
    if echo "$IDLE" | grep -q '^timeout .*output.*off'; then
        BLANKING="on"
        MASK=$(( MASK + 1 ))
    else
        BLANKING="off"
    fi
    case $MASK in
        0)   MODE="movie-mode" ;;
        1)   MODE="at-home-mode" ;;
        111) MODE="safe-mode" ;;
        101) MODE="download-mode" ;;
        *)   MODE="unknown mode!" ;;
    esac

    echo "$MODE: blanking=$BLANKING auto-lock=$LOCKING auto-suspend=$SUSPEND

$IDLE"
}

# set timeout value:
[[ "$1" && $1 =~ [0-9]+ ]] && {
    TIMEOUT=$1
    shift
}

# do we need a dialog?
[[ -z "$1" ]] && {
    # add key bindings to MODES
    
    # query key bindings from sway config file:
    get_binding_for() {
        TARGET=$1

        awk "/^bindsym.* $PROG.* $TARGET/ "'{ print " ["$2"]"; exit 0 }' "$BINDINGS_FILE"
    }

    BLANK_BINDING=$( get_binding_for "blank" )
    LOCK_NOW_BINDING=$( get_binding_for "lock-now" )
    AT_HOME_MODE_BINDING=$( get_binding_for "at-home-mode" )
    MOVIE_MODE_BINDING=$( get_binding_for "movie-mode" )
    SAFE_MODE_BINDING=$( get_binding_for "safe-mode" )
    DOWNLOAD_MODE_BINDING=$( get_binding_for "download-mode" )
    DESKTOP_MODE_BINDING=$( get_binding_for "desktop-mode" )

    VAL=$(
        echo "$MODES" |
        sed \
            -e "/blank:/s/\$/$BLANK_BINDING/" \
            -e "/lock-now:/s/\$/$LOCK_NOW_BINDING/" \
            -e "/safe:/s/\$/$SAFE_MODE_BINDING/" \
            -e "/at-home:/s/\$/$AT_HOME_MODE_BINDING/" \
            -e "/download:/s/\$/$DOWNLOAD_MODE_BINDING/" \
            -e "/desktop:/s/\$/$DESKTOP_MODE_BINDING/" \
            -e "/movie:/s/\$/$MOVIE_MODE_BINDING/" |
        grep -v '(resume):' |
        wofi --cache-file=/dev/null --dmenu --lines 8 -p "$PROG: presently $( get_current_idle | head -n 1 )" ) || exit 0

    # shellcheck disable=SC2086
    set -- $VAL
}

WAIT='-w' # does this cause the double login? No - it happens without it!

WOFI_MSG=""

swaymsg "output * dpms on"

MODE="$1"

case "$MODE" in
    "blank"*)
        swaymsg "output * dpms off"
        echo "Hit Enter or ESC to unblank" | wofi --dmenu
        swaymsg "output * dpms on"
        ;;
    
    "lock"*) # includes lock-now!!

        # lock keepassxc:
        qdbus org.keepassxc.KeePassXC.MainWindow /keepassxc org.keepassxc.MainWindow.lockAllDatabases
        
        if [[ -z "$IMAGE" ]] && [[ "$DOWNLOAD_RANDOM_IMAGE" ]]; then
            # fetch a download random image from unsplash.it:
            IMAGE="$IMAGE_COLLECTION/unsplash.it-$( date +"%Y%m%dT%H%M%S" ).jpg"

            #FIXME: allow user to cancel it
            echo "Downloading image from $IMAGE_URL ..." |
            wofi --cache-file=/dev/null --dmenu --lines 1 -p "$PROG" >/dev/null & WOFI_PID=$!
            
            wget -q -O "$IMAGE" "$IMAGE_URL" || {
                echo "$PROG: download from '$IMAGE_URL' failed" >&2
                # exit 1 # probably better to lock with a blank screen or an image from $XDG_PICTURES_DIR
                IMAGE=""
            }

            kill $WOFI_PID
        fi
        
        [[ "$IMAGE" ]] || {
            # get a random image from our collection:
            IMAGE="$( find "$IMAGE_COLLECTION" -type f | shuf -n 1 )"
        }
        
        pkill "$LOCK_PROGRAM"

        NWG_WRAPPER_PIDS=""
        if type nwg-wrapper && [[ "$NWG_WRAPPER" ]]; then
            # shellcheck disable=SC2086
            nwg-wrapper -s timezones.sh -r 10000 -c timezones.css -p right -mr 50 -a start -mt 50 -j right --layer 3 &
            sleep 1.5
            
            NWG_WRAPPER_PIDS=$!

            IMAGE_TITLE=""
            if [[ "$DOWNLOAD_RANDOM_IMAGE" ]]; then
                IMAGE_TITLE="$IMAGE_URL"
            elif [[ "$IMAGE" ]]; then
                IMAGE_TITLE=$( basename "$IMAGE" )
            fi
            if [[ "$IMAGE_TITLE" ]]; then
                echo "<span size='25000' foreground='#ffffff' weight='light'>$IMAGE_TITLE</span>" |
                nwg-wrapper -t "/dev/stdin" -r 10000 -c timezones.css -a end -j center --layer 3 &
                NWG_WRAPPER_PIDS+=" $!"
            fi
            sleep 1.5
        fi

        echo "$PROG: $IMAGE" >> "$HOME/.cache/$PROG.log"
        case "$LOCK_PROGRAM" in
            swaylock)
                swaylock --image "$IMAGE" &
                ;;
            gtklock)
                CSS_OPT=""
                [[ -d "$GTKLOCK_CONFIG_DIR" ]] || mkdir "$GTKLOCK_CONFIG_DIR"
                GTKLOCK_CSS=$GTKLOCK_CONFIG_DIR/$PROG.css
                [[ -e "$GTKLOCK_CSS" ]] || {
                    cat > "$GTKLOCK_CSS" << EOF
window {
   background-image: url("foo.jpg");
   background-size: cover;
   background-repeat: no-repeat;
   background-position: center;
   background-color: black;
}
EOF
                }
                
                [[ -w $GTKLOCK_CSS ]] && {
                    sed -i '/background-image/d' "$GTKLOCK_CSS"
                    # shellcheck disable=SC1004
                    sed -i '/{/a \
   background-image: url("'"$IMAGE"'");' "$GTKLOCK_CSS"
                    CSS_OPT="-s $GTKLOCK_CSS"
                }
                # shellcheck disable=SC2086
                gtklock -d $CSS_OPT &
                ;;
            esac
                
        
        # avoid double lock before-sleep - put $LOCK_PROGRAM into
        # background so that we can return for the -w option, then:
        sleep 1

        if [[ "$NWG_WRAPPER_PIDS" ]]; then
            (
                while pkill -0 "$LOCK_PROGRAM"; do
                    sleep 1
                done
                # shellcheck disable=SC2086
                kill -9 $NWG_WRAPPER_PIDS
            ) &
        fi

        # clean up if necessary:
        [[ "$DOWNLOAD_RANDOM_IMAGE" ]] && [[ "$DELETE_DOWNLOADED_IMAGE" ]] && { sleep 10; rm "$IMAGE" & }
        ;;

    "resume")
        swaymsg 'output * dpms on'
        ;;

    "safe"*)
        pkill swayidle
        swayidle $WAIT \
                 timeout "$TIMEOUT"              "swaymsg 'output * dpms off'" \
                 resume                          "$SELF resume" \
                 timeout $(( TIMEOUT * 2 ))      "swaymsg 'output * dpms on'; $SELF lock-now" \
                 resume                          "$SELF resume" \
                 timeout $(( TIMEOUT * 3 ))      "swaymsg 'output * dpms off'" \
                 resume                          "$SELF resume" \
                 timeout $(( TIMEOUT * 4 ))      "sudo systemctl suspend" \
                 before-sleep                    "$SELF lock-now" &
        
        WOFI_MSG="safe-mode: auto-lock and auto-suspend are enabled (timeout=$TIMEOUT secs)"
        ;;
        
    "at-home"*)
        pkill swayidle
        swayidle $WAIT \
                 timeout "$TIMEOUT" "swaymsg 'output * dpms off'" \
                 resume             "$SELF resume" \
                 before-sleep       "$SELF lock-now" \
                 after-resume       "$SELF safe-mode" &
        
        WOFI_MSG="at-home-mode: auto-lock and auto-suspend are disabled (until manual suspend)"
        ;;

    "download"*|"desktop"*)
        pkill swayidle
        swayidle $WAIT \
                 timeout "$TIMEOUT"              "swaymsg 'output * dpms off'" \
                 resume                          "$SELF resume" \
                 timeout $(( TIMEOUT * 2 ))      "swaymsg 'output * dpms on'; $SELF lock-now" \
                 resume                          "$SELF resume" \
                 timeout $(( TIMEOUT * 3 ))      "swaymsg 'output * dpms off'" \
                 resume                          "$SELF resume" \
                 before-sleep                    "$SELF lock-now" &

        WOFI_MSG="download/desktop-mode: auto-lock is enabled (timeout=$TIMEOUT secs); auto-suspend is disabled"
        ;;

    "movie"*)
        pkill swayidle
        swayidle $WAIT \
                 before-sleep      "$SELF lock-now" \
                 after-resume      "$SELF safe-mode" &
        

        WOFI_MSG="movie-mode: blanking, auto-lock and auto-suspend are disabled (until manual suspend)"
        ;;

esac

[[ "$NOTIFY" && "$WOFI_MSG" ]] && {
    notify-send --expire-time=5000 "${WOFI_MSG%:*}"
}

# ignore WOFI_MSG except as a flag:
[[ "$WOFI_MSG" && -z "$QUIET" ]] && {
    get_current_idle | if type zenity; then
        zenity --width=600 --height=300 --text-info --title=foo
    else
        wofi --style=/dev/null --cache-file=/dev/null --dmenu -p "$PROG" >/dev/null
    fi
}

exit 0

# Local Variables:
# mode: shell-script
# time-stamp-pattern: "4/TIME_STAMP=\"%:y%02m%02d.%02H%02M%02S\""
# eval: (add-hook 'before-save-hook 'time-stamp)
# End:


