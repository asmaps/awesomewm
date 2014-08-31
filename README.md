#awesomewm

Config files for the awesome window manager

## Requirements

Probably only works on debian (and maybe ubuntu).
Also requires awesome 3.4


## Usage

Install vicious. On debian based systems install `awesome-extra` package.

Symlink rc.lua and icons folder to your ~/.config/awesome/ by using ` init.sh`.


## required files

create the file ~/.config/awesome/username-hostname.lua for your specific config.

This file must set:

```
# command to start your screensaver/lock pc
screensaver_cmd = 'i3lock'
```
