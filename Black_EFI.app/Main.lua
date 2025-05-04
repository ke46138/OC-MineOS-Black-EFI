local GUI = require("GUI")
local system = require("System")
local eeprom = component.eeprom
local internet = require("Internet")
local filesystem = require("filesystem")

local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 60, 20, 0xE1E1E1))

local localization = system.getCurrentScriptLocalization()

local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))

local osboot = true

local osbootswitch = layout:addChild(GUI.switchAndLabel(2, 2, 38, 7, 0x66DB80, 0x1D1D1D, 0xEEEEEE, 0x999999, localization.osbootswitch, true))
osbootswitch.switch.onStateChanged = function(state)
  osboot = state
end

layout:addChild(GUI.button(2, 2, 30, 3, 0xFFFFFF, 0x555555, 0x2d2d2d, 0xFFFFFF, localization.flash)).onTouch = function()
  local data, reason = internet.request("https://github.com/ke46138/OC-MineOS-Black-EFI/raw/refs/heads/main/bios.lua")
  if data then
    local success, reason, reasonFromEeprom = pcall(eeprom.set, data)
    if success and not reasonFromEeprom then
      eeprom.setLabel("Black Mine EFI")
      eeprom.setData(require("filesystem").getProxy().address)
    else
      GUI.alert(localization.fail)
    end
  else
    GUI.alert(localization.fail)
  end
  
  if osboot == true then
    local success, reason = filesystem.rename("/OS.lua", "/OS.lua.back")
    if success == false then
      GUI.alert(reason)
      return
    end
    local dsuccess, dreason = internet.download("https://github.com/ke46138/OC-MineOS-Black-EFI/raw/refs/heads/main/OS.lua", "/OS.lua")
    if dsuccess == false then
      GUI.alert(dreason)
      return
    end
  end
  GUI.alert(localization.success)
end

window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
end

workspace:draw()
