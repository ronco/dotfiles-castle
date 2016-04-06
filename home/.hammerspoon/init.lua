-- Based on https://raw.githubusercontent.com/cmsj/hammerspoon-config/master/init.lua
-- see http://www.tenshu.net/p/fake-hyper-key-for-osx.html for hyper key setup

-- Seed the RNG
math.randomseed(os.time())

-- Capture the hostname, so we can make this config behave differently across my Macs
hostname = hs.host.localizedName()

-- Ensure the IPC command line client is available
hs.ipc.cliInstall()

-- Watchers and other useful objects
local configFileWatcher = nil
local wifiWatcher = nil
local screenWatcher = nil
local usbWatcher = nil
local caffeinateWatcher = nil
local appWatcher = nil

local mouseCircle = nil
local mouseCircleTimer = nil

-- Define some keyboard modifier variables
-- (Node: Left-Ctrl bound to cmd+alt+ctrl+shift via Seil and Karabiner)
local hyper = {"⌘", "⌥", "⌃", "⇧"}

-- Define monitor names for layout purposes
local display_laptop = "Color LCD"
local display_dell = "DELL U2415"

-- Defines for WiFi watcher
local homeSSID = "Whistello-5G" -- My home WiFi SSID
local lastSSID = hs.wifi.currentNetwork()

-- Defines for screen watcher
local lastNumberOfScreens = #hs.screen.allScreens()

-- Defines for window grid
hs.grid.GRIDWIDTH = 8
hs.grid.GRIDHEIGHT = 8
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

-- Define dev windows to look for
local chromeDevWindows = {
   ".*- Ibotta%.com.*",
   ".*Ibotta - Better than Coupons.*",
   ".*IbottaWeb Tests.*",
   ".*Partner Portal.*",
   ".*Pp Tests.*",
   ".*Ibotta Customer Support Tool.*",
   ".*Cs Tests.*"
}

local emacsCompilationWindows = {
   "%*rspec%-compilation%*"
}

-- Defines for window maximize toggler
local frameCache = {}

-- Define window layouts
local topLeftRect = hs.geometry.unitrect(0, 0, 0.5, 0.5)
local topRightRect = hs.geometry.unitrect(0.5, 0, 0.5, 0.5)
local bottomLeftRect = hs.geometry.unitrect(0, 0.5, 0.5, 0.5)
local bottomRightRect = hs.geometry.unitrect(0.5, 0.5, 0.5, 0.5)
local topLeftFatRect = hs.geometry.unitrect(0, 0, 0.6, 0.5)
local topRightFatRect = hs.geometry.unitrect(0.4, 0, 0.6, 0.5)
local bottomLeftFatRect = hs.geometry.unitrect(0, 0.5, 0.6, 0.5)
local bottomRightFatRect = hs.geometry.unitrect(0.4, 0.5, 0.6, 0.5)

-- Helper functions

function debounce(func, wait, immediate)
   local timeout = false
   return function()
     local later = function()
       timeout = nil
       if not immediate then func() end
     end
     local callNow = immediate and not timeout
     if timeout then timeout:stop() end
     timeout = hs.timer.doAfter(wait, later)
     if callNow then func() end
   end
end

-- window finder

function find_active_window_title(patterns)
   for _,v in pairs(patterns) do
      local win = hs.appfinder.windowFromWindowTitlePattern(v)
      if win then
         return win:title()
      end
   end
end

-- screen finder

function find_external_screen(orientation)
   if not orientation then orientation = 'landscape' end
   allscreens = hs.screen.allScreens()
   if orientation == 'landscape' then
      return find_screen(function(desc) return desc['w'] > desc['h'] end, allscreens)
   elseif orientation == 'portrait' then
      return find_screen(function(desc) return desc['h'] > desc['w'] end, allscreens)
   end
end

function find_screen(comparator, screens)
   i = table.find_index(comparator, map(function(screen) return screen:currentMode() end, screens))
   if i then
      return screens[i]
   end
end

-- layout builder

function build_layout(numberOfScreens)
   print("Building layout for " .. numberOfScreens .. " screens")
   -- TODO: memo-ize screens
   local primaryScreen, secondaryScreen, tertiaryScreen = get_screens(numberOfScreens)
   -- print("primaryScreen: ")
   -- print(hs.inspect(primaryScreen))
   -- print("secondaryScreen: ")
   -- print(hs.inspect(secondaryScreen))
   -- print("tertiaryScreen: ")
   -- print(hs.inspect(tertiaryScreen))
   --   Format reminder:
   --     {"App name", "Window name", "Display Name", "unitrect", "framerect", "fullframerect"},
   local iTunesMiniPlayerLayout = {"iTunes", "MiniPlayer", display_laptop, nil, nil, hs.geometry.rect(0, -48, 400, 48)}
   local layout = {}
   local devChromeTitle = find_active_window_title(chromeDevWindows)
   local emacsCompilationTitle = find_active_window_title(emacsCompilationWindows)
   local compilationScreen = primaryScreen
   local primaryEmacsLayout = hs.layout.maximized
   local compilationEmacsLayout = hs.layout.maximized
   if numberOfScreens == 1 then
      if emacsCompilationTitle then
         primaryEmacsLayout = hs.layout.left50
         compilationEmacsLayout = hs.layout.right50
      end
      layout = {
         {"Google Chrome", nil,      display_laptop, hs.layout.maximized, nil, nil},
         {"HipChat",       nil,      display_laptop, bottomLeftFatRect, nil, nil},
         {"1Password 6",   nil,      display_laptop, hs.layout.maximized, nil, nil},
         {"Calendar",      nil,      display_laptop, hs.layout.maximized, nil, nil},
         {"Messages",      nil,      display_laptop, topLeftRect, nil, nil},
         {"Slack",         nil,      display_laptop, topRightFatRect, nil, nil},
         {"Evernote",      nil,      display_laptop, hs.layout.maximized, nil, nil},
         {"iTunes",        "iTunes", display_laptop, hs.layout.maximized, nil, nil},
         {"iTerm",         nil,      display_laptop, hs.layout.maximized, nil, nil},
         iTunesMiniPlayerLayout,
      }
   elseif numberOfScreens == 2 then
      if emacsCompilationTitle then
         primaryEmacsLayout = hs.layout.left50
         compilationEmacsLayout = hs.layout.right50
      end
      layout = {
         {"Google Chrome", nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"HipChat",       nil,      secondaryScreen, bottomLeftFatRect, nil, nil},
         {"1Password 6",   nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"Calendar",      nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"Messages",      nil,      secondaryScreen, topLeftRect, nil, nil},
         {"Slack",         nil,      secondaryScreen, topRightFatRect, nil, nil},
         {"Evernote",      nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"iTunes",        "iTunes", secondaryScreen, hs.layout.maximized, nil, nil},
         {"iTerm",         nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"Dash",          nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         iTunesMiniPlayerLayout,
      }
   elseif numberOfScreens == 3 then
      compilationScreen = tertiaryScreen
      layout = {
         {"Google Chrome", nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"HipChat",       nil,      secondaryScreen, bottomLeftFatRect,   nil, nil},
         {"1Password 6",   nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"Calendar",      nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"Messages",      nil,      secondaryScreen, topLeftRect,         nil, nil},
         {"Slack",         nil,      secondaryScreen, topRightFatRect,     nil, nil},
         {"Evernote",      nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         {"iTunes",        "iTunes", secondaryScreen, hs.layout.maximized, nil, nil},
         {"iTerm",         nil,      tertiaryScreen,  hs.layout.maximized, nil, nil},
         {"Dash",          nil,      secondaryScreen, hs.layout.maximized, nil, nil},
         iTunesMiniPlayerLayout,
      }
      if devChromeTitle then
         table.insert(layout,
            {"Chrome", devChromeTitle,     tertiaryScreen,  hs.layout.maximized, nil, nil}
         )
      end
   end
   table.insert(layout,
      {"Emacs", nil, primaryScreen, primaryEmacsLayout, nil, nil}
   )
   if emacsCompilationTitle then
      table.insert(layout,
                   {"Emacs", emacsCompilationTitle, compilationScreen, compilationEmacsLayout, nil, nil}
      )
   end

   return layout
end

function get_screens(numberOfScreens)
   local primary = hs.screen.primaryScreen()
   local secondary, tertiary = nil, nil
   local secondaryScreens = table.filter(function(screen) return not (screen == primary) end, hs.screen.allScreens())
   for _, v in pairs(secondaryScreens) do
      if not secondary then
         secondary = v
      else
         ax = secondary:position()
         bx = v:position()
         if ax > bx then
            tertiary = secondary
            secondary = v
         else
            tertiary = v
         end
      end
   end
   return primary, secondary, tertiary
end

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
    local app = hs.appfinder.appFromName(_app)
    if not app then
        -- FIXME: This should really launch _app
        return
    end
    local mainwin = app:mainWindow()
    if mainwin then
        if mainwin == hs.window.focusedWindow() then
            mainwin:application():hide()
        else
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
        end
    end
end

-- Toggle a window between its normal size, and being maximized
function toggle_window_maximized()
    local win = hs.window.focusedWindow()
    if frameCache[win:id()] then
        win:setFrame(frameCache[win:id()])
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize()
    end
end

-- Callback function for WiFi SSID change events
function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    print("ssidChangedCallback: old:"..(lastSSID or "nil").." new:"..(newSSID or "nil"))
    if newSSID == homeSSID and lastSSID ~= homeSSID then
        -- We have gone from something that isn't my home WiFi, to something that is
        home_arrived()
    elseif newSSID ~= homeSSID and lastSSID == homeSSID then
        -- We have gone from something that is my home WiFi, to something that isn't
        home_departed()
    end

    lastSSID = newSSID
end

-- Callback for usb changes
function usbDeviceCallback(data)
   print("usbDeviceCallback: "..hs.inspect(data))
   if (data["productName"] == "USB 10/100/1000 LAN") then
      event = data["eventType"]
      if (event == "added") then
         hs.wifi.setPower(false)
      elseif (event == "removed") then
         hs.wifi.setPower(true)
      end
   end
end

-- Callback function for changes in screen layout
function screensChangedCallback()
    print("screensChangedCallback")
    newNumberOfScreens = #hs.screen.allScreens()

    -- FIXME: This is awful if we swap primary screen to the external display. all the windows swap around, pointlessly.
    if lastNumberOfScreens ~= newNumberOfScreens then
       setDisplayLayout(newNumberOfScreens)
    end

    lastNumberOfScreens = newNumberOfScreens

end

function setDisplayLayout(newNumberOfScreens)
   hs.layout.apply(build_layout(newNumberOfScreens))
   hs.notify.new({
         title='Hammerspoon',
         informativeText='Display set to ' .. newNumberOfScreens
   }):send()
end

-- Perform tasks to configure the system for my home WiFi network
function home_arrived()
    hs.notify.new({
          title='Hammerspoon',
            informativeText='Arrived Home'
        }):send()
end

-- Perform tasks to configure the system for any WiFi network other than my home
function home_departed()
    hs.notify.new({
          title='Hammerspoon',
            informativeText='Left Home'
        }):send()
end

-- I always end up losing my mouse pointer, particularly if it's on a monitor full of terminals.
-- This draws a bright red circle around the pointer for a few seconds
function mouseHighlight()
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    mousepoint = hs.mouse.getAbsolutePosition()
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:bringToFront(true)
    mouseCircle:show(0.5)

    mouseCircleTimer = hs.timer.doAfter(3, function()
        mouseCircle:hide(0.5)
        hs.timer.doAfter(0.6, function() mouseCircle:delete() end)
    end)
end

-- Rather than switch to Safari, copy the current URL, switch back to the previous app and paste,
-- This is a function that fetches the current URL from Safari and types it
function typeCurrentSafariURL()
    script = [[
    tell application "Safari"
        set currentURL to URL of document 1
    end tell

    return currentURL
    ]]
    ok, result = hs.applescript(script)
    if (ok) then
        hs.eventtap.keyStrokes(result)
    end
end

-- Reload config
function reloadConfig(paths)
    doReload = false
    for _,file in pairs(paths) do
        if file:sub(-4) == ".lua" then
            print("A lua file changed, doing reload")
            doReload = true
        end
    end
    if not doReload then
        print("No lua file changed, skipping reload")
        return
    end

    hs.reload()
end

-- Hotkeys to move windows between screens, retaining their position/size relative to the screen
hs.urlevent.bind('hyperoptionleft', function() hs.window.focusedWindow():moveOneScreenWest() end)
hs.urlevent.bind('hyperoptionright', function() hs.window.focusedWindow():moveOneScreenEast() end)

-- Hotkeys to resize windows absolutely
hs.hotkey.bind(hyper, 'a', function() hs.window.focusedWindow():moveToUnit(hs.layout.left30) end)
hs.hotkey.bind(hyper, 's', function() hs.window.focusedWindow():moveToUnit(hs.layout.right70) end)
hs.hotkey.bind(hyper, '[', function() hs.window.focusedWindow():moveToUnit(hs.layout.left50) end)
hs.hotkey.bind(hyper, ']', function() hs.window.focusedWindow():moveToUnit(hs.layout.right50) end)
hs.hotkey.bind(hyper, 'p', function() hs.window.focusedWindow():moveToUnit(hs.geometry.unitrect(0, 0, 1, 0.5)) end)
hs.hotkey.bind(hyper, 'n', function() hs.window.focusedWindow():moveToUnit(hs.geometry.unitrect(0, 0.5, 1, 0.5)) end)
hs.hotkey.bind(hyper, 'f', toggle_window_maximized)
hs.hotkey.bind(hyper, 'r', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Hotkeys to trigger defined layouts
hs.hotkey.bind(hyper, '1', function() setDisplayLayout(1) end)
hs.hotkey.bind(hyper, '2', function() setDisplayLayout(2) end)
hs.hotkey.bind(hyper, '3', function() setDisplayLayout(3) end)

-- Hotkeys to interact with the window grid
hs.hotkey.bind(hyper, 'g', hs.grid.show)
hs.hotkey.bind(hyper, 'Left', hs.grid.pushWindowLeft)
hs.hotkey.bind(hyper, 'Right', hs.grid.pushWindowRight)
hs.hotkey.bind(hyper, 'Up', hs.grid.pushWindowUp)
hs.hotkey.bind(hyper, 'Down', hs.grid.pushWindowDown)

hs.urlevent.bind('hypershiftleft', function() hs.grid.resizeWindowThinner(hs.window.focusedWindow()) end)
hs.urlevent.bind('hypershiftright', function() hs.grid.resizeWindowWider(hs.window.focusedWindow()) end)
hs.urlevent.bind('hypershiftup', function() hs.grid.resizeWindowShorter(hs.window.focusedWindow()) end)
hs.urlevent.bind('hypershiftdown', function() hs.grid.resizeWindowTaller(hs.window.focusedWindow()) end)

-- Application hotkeys
hs.hotkey.bind(hyper, 't', function() toggle_application("iTerm") end)
hs.hotkey.bind(hyper, 'e', function() toggle_application("Emacs") end)
hs.hotkey.bind(hyper, 'q', function() toggle_application("Google Chrome") end)

-- caffeinate hotkeys
hs.urlevent.bind('hypershiftz', function() hs.caffeinate.startScreensaver() end)

-- Misc hotkeys
hs.hotkey.bind(hyper, 'y', hs.toggleConsole)
hs.hotkey.bind(hyper, 'd', mouseHighlight)
hs.hotkey.bind(hyper, '0', function()
    print(configFileWatcher)
    print(wifiWatcher)
    print(screenWatcher)
    print(usbWatcher)
end)

-- Create and start our callbacks
-- appWatcher = hs.application.watcher.new(applicationWatcher):start()

screenWatcher = hs.screen.watcher.new(debounce(screensChangedCallback, 5))
screenWatcher:start()

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configFileWatcher:start()

usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()

-- Make sure we have the right location settings
if hs.wifi.currentNetwork() == homeSSID then
    home_arrived()
else
    home_departed()
end

-- Finally, show a notification that we finished loading the config successfully
hs.notify.new({
      title='Hammerspoon',
        informativeText='Config loaded'
    }):send()


collectgarbage("setstepmul", 1000)
collectgarbage("setpause", 1)

-- Lua patches, common, why is this not in stdlib

function table.set(t) -- set of list
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end

function table.find(f, l) -- find element v of l satisfying f(v)
  for _, v in ipairs(l) do
    if f(v) then
      return v
    end
  end
  return nil
end

function table.find_index(f, l) -- find element v of l satisfying f(v)
  for i, v in ipairs(l) do
    if f(v) then
      return i
    end
  end
  return nil
end

function map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

table.filter = function(filterIter, t)
  local out = {}

  for k, v in pairs(t) do
    if filterIter(v, k, t) then out[k] = v end
  end

  return out
end
