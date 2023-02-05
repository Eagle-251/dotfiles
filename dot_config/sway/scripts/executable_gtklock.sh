#!/bin/sh

outputs=$(swaymsg -r -t get_outputs | jq -r ".[].name")

for o in $outputs
do
	grim -o "$o" "/tmp/$o.png"
	corrupter "/tmp/$o.png" "/tmp/$o.png" &
done
wait
exec gtklock -s ~/.config/gtklock/style.css "$@"
