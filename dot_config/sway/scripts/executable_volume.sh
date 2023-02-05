#!/bin/bash

case "$1" in
        'up')
                pw-volume change +4% &>/dev/null
                pkill -RTMIN+8 waybar
                notify-send 'Volume: ' -h int:value:"$(pw-volume status | jq '.percentage')"
                ;;
        'down')
                pw-volume change -4% &>/dev/null
                pkill -RTMIN+8 waybar
                notify-send 'Volume: ' -h int:value:"$(pw-volume status | jq '.percentage')"
                ;;
        'mute')
                pw-volume mute toggle &>/dev/null 
                pkill -RTMIN+8 waybar
                notify-send 'Volume: ' -h int:value:"$(pw-volume status | jq '.percentage')"
                ;;
        #
        # *)
        #         echo "Not the right arguments"
        #         echo "$1"
        #         exit 2
esac
