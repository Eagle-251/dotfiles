#!/bin/bash



case "$1" in
        'up')
                brightnessctl set 5%+ &>/dev/null
                pkill -RTMIN+8 waybar
               notify-send "Brightness: " -h int:value:$(brightnessctl | grep "Current brightness" | cut -d " " -f 4 | sed 's/(//g;s/)//g;s/%//g') 
                ;;
        'down')
                brightnessctl set 5%- &>/dev/null
                pkill -RTMIN+8 waybar
               notify-send "Brightness: " -h int:value:$(brightnessctl | grep "Current brightness" | cut -d " " -f 4 | sed 's/(//g;s/)//g;s/%//g') 
                ;;
esac

