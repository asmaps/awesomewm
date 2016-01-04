#!/bin/bash

echo "init awesomeness"
mkdir -p ~/.config/awesome/

ln -fs `pwd`/rc.lua ~/.config/awesome/rc.lua
ln -fs `pwd`/theme.lua ~/.config/awesome/theme.lua
ln -fs `pwd`/lock.sh ~/.config/awesome/lock.sh
ln -fs `pwd`/icons ~/.config/awesome/

