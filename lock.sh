#!/bin/bash
# credits to https://github.com/savoca/dotfiles/blob/dark/.bin/scripts/lock.sh

scrot /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png
[[ -f $1 ]] && convert /tmp/screen.png $1 -gravity center -composite -matte /tmp/screen.png
i3lock -i /tmp/screen.png
rm /tmp/screen.png
