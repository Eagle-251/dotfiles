#!/bin/bash




getWeather () {
    echo "set weather $(curl -s 'wttr.in/?format=%C')"
}

parse_temp () {  
    raw_temp=$(curl -s 'wttr.in/?format=%t')
    if [ $(echo $raw_temp | sed  's/+//;s/°C//') -lt 12 ]; then
        echo "set temp (set_color blue; echo $raw_temp; set_color normal)"
    else
        echo "set temp (set_color red; echo $raw_temp; set_color normal)"
    fi
}

getWeather > ~/.prompt/weather

parse_temp > ~/.prompt/temp
