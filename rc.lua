local io = require("io")
local gears = require("gears")
local wibox = require("wibox")
-- Standard awesome library
local awful = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

-- widgets
local vicious = require("vicious")

-- Load Debian menu entries
local debianmenu = require("debian.menu")

-- autostart helper:
function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    if not arg_string then 
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end

hostname = io.popen("uname -n"):read()
username = io.popen("whoami"):read()
require(username .. "-" .. hostname)

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debianmenu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- }}}

-- {{{ Wibox
-- Create a textclock widget
clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.widget_clock)
mytextclock = awful.widget.textclock()

-- create a battery widget

baticon = wibox.widget.imagebox()
baticon:set_image(awful.util.getdir("config") .. "/icons/bat.png")

batwidget0 = wibox.widget.textbox()
batwidget1 = wibox.widget.textbox()
vicious.register(batwidget0, vicious.widgets.bat, function (widget, args)
	-- different widget appearance
	--
	b_dis = "▼ "
	b_cha = "▲ "

	if  args[2] < 30 and args[2] >= 15 and args[1] == "-" then
		return "" .. "<b>" .. b_dis ..  args[2] .. "</b>% <b>" ..args[3] .. "</b>"  .. ""
	elseif args[2] < 15 and args[1] == "-" then
		return "" .. "<b>" .. b_dis.. args[2] .. "</b>% <b>" .. args[3] .. "</b>" .. ""
	elseif args[1] == "-" then
		return "<b>" .. b_dis .. args[2].. "</b>% (<b>" .. args[3] .. "</b>)"
	elseif args[1] == "+" then
		return "" .. b_cha .. "<b>" .. args[2] .. "</b>%"
	else
		return "<b>" .. args[1] .. "</b>"
	end
end, 10, "BAT0")
vicious.register(batwidget1, vicious.widgets.bat, function (widget, args)
	-- different widget appearance
	--
	b_dis = "▼ "
	b_cha = "▲ "

	if  args[2] < 30 and args[2] >= 15 and args[1] == "-" then
		return "" .. "<b>" .. b_dis ..  args[2] .. "</b>% <b>" ..args[3] .. "</b>"  .. ""
	elseif args[2] < 15 and args[1] == "-" then
		return "" .. "<b>" .. b_dis.. args[2] .. "</b>% <b>" .. args[3] .. "</b>" .. ""
	elseif args[1] == "-" then
		return "<b>" .. b_dis .. args[2].. "</b>% (<b>" .. args[3] .. "</b>)"
	elseif args[1] == "+" then
		return "" .. b_cha .. "<b>" .. args[2] .. "</b>%"
	else
		return "<b>" .. args[1] .. "</b>"
	end
end , 10, "BAT1")

separator = wibox.widget.imagebox()
separator:set_image(awful.util.getdir("config") .. "/icons/separator.png")

timeicon = wibox.widget.imagebox()
timeicon:set_image(awful.util.getdir("config") .. "/icons/time.png")

spacer = wibox.widget.textbox()
spacer.width = 3

-- Create a systray
mysystray = wibox.widget.systray()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(spacer)
    right_layout:add(separator)
    right_layout:add(spacer)
    right_layout:add(batwidget1)
    right_layout:add(spacer)
    right_layout:add(baticon)
    right_layout:add(spacer)
    right_layout:add(separator)
    right_layout:add(spacer)
    right_layout:add(batwidget0)
    right_layout:add(spacer)
    right_layout:add(baticon)
    right_layout:add(spacer)
    right_layout:add(separator)
    right_layout:add(spacer)

    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(timeicon)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "Insert", run_once("xmodmap -e \"keycode 118 = End\"")),


    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,  	  }, "Up", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,  	  }, "Down", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ "Control", "Mod1" }, "l", function() run_once('~/.config/awesome/lock.sh') end),

    -- Display configs
    awful.key({ modkey,           }, "F1", function() run_once('~/.screenlayout/1screen.sh') end),
    awful.key({ modkey,           }, "F2", function() run_once('~/.screenlayout/2screens.sh') end),
    awful.key({ modkey,           }, "F3", function() run_once('~/.screenlayout/3screens.sh') end),
    awful.key({ modkey,           }, "F4", function() run_once('~/.screenlayout/3screens_home.sh') end),

    -- brightness settings
    awful.key({ "Control", "Mod1" }, "1", function() run_once("xbacklight -set 1") end),
    awful.key({ "Control", "Mod1" }, "2", function() run_once("xbacklight -set 2") end),
    awful.key({ "Control", "Mod1" }, "3", function() run_once("xbacklight -set 5") end),
    awful.key({ "Control", "Mod1" }, "4", function() run_once("xbacklight -set 10") end),
    awful.key({ "Control", "Mod1" }, "5", function() run_once("xbacklight -set 15") end),
    awful.key({ "Control", "Mod1" }, "6", function() run_once("xbacklight -set 23") end),
    awful.key({ "Control", "Mod1" }, "7", function() run_once("xbacklight -set 35") end),
    awful.key({ "Control", "Mod1" }, "8", function() run_once("xbacklight -set 50") end),
    awful.key({ "Control", "Mod1" }, "9", function() run_once("xbacklight -set 75") end),
    awful.key({ "Control", "Mod1" }, "0", function() run_once("xbacklight -set 100") end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    elseif not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count change
        awful.placement.no_offscreen(c)
    end

    -- local titlebars_enabled = false
    -- if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
    --     -- buttons for the titlebar
    --     local buttons = awful.util.table.join(
    --             awful.button({ }, 1, function()
    --                 client.focus = c
    --                 c:raise()
    --                 awful.mouse.client.move(c)
    --             end),
    --             awful.button({ }, 3, function()
    --                 client.focus = c
    --                 c:raise()
    --                 awful.mouse.client.resize(c)
    --             end)
    --             )
    --
    --     -- Widgets that are aligned to the left
    --     local left_layout = wibox.layout.fixed.horizontal()
    --     left_layout:add(awful.titlebar.widget.iconwidget(c))
    --     left_layout:buttons(buttons)
    --
    --     -- Widgets that are aligned to the right
    --     local right_layout = wibox.layout.fixed.horizontal()
    --     right_layout:add(awful.titlebar.widget.floatingbutton(c))
    --     right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    --     right_layout:add(awful.titlebar.widget.stickybutton(c))
    --     right_layout:add(awful.titlebar.widget.ontopbutton(c))
    --     right_layout:add(awful.titlebar.widget.closebutton(c))
    --
    --     -- The title goes in the middle
    --     local middle_layout = wibox.layout.flex.horizontal()
    --     local title = awful.titlebar.widget.titlewidget(c)
    --     title:set_align("center")
    --     middle_layout:add(title)
    --     middle_layout:buttons(buttons)
    --
    --     -- Now bring it all together
    --     local layout = wibox.layout.align.horizontal()
    --     layout:set_left(left_layout)
    --     layout:set_right(right_layout)
    --     layout:set_middle(middle_layout)
    --
    --     awful.titlebar(c):set_widget(layout)
    -- end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- run_once("xscreensaver","-no-splash")
-- run_once("nm-applet","")
-- run_once("xfsettingsd","")
-- run_once("xfce4-power-manager","")
run_once("setxkbmap -model pc105 -layout de -variant nodeadkeys")
run_once("feh --bg-scale .config/awesome/themes/default/background.png")
run_once("xmodmap -e \"keycode 118 = End\"")
