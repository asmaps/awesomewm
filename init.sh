#!/bin/bash

echo "init awesomeness"
mkdir -p ~/.config/awesome/

ln -fs `pwd`/rc.lua ~/.config/awesome/rc.lua
ln -fs `pwd`/icons ~/.config/awesome/

