local buildMode = ...
local FILE_PATH = "/SCRIPTS/TELEMETRY/SnakeHD/"
local FLASH = 3
local SMLCD = LCD_W < 212
local HORUS = LCD_W >= 480
local v, r, m, i, e = getVersion()
local env = "tc"

print("")
print("--------------------- COMPILE SCRIPTS ---------------------")
print("")

-- local data, PREV, NEXT, MENU = loadScript(FILE_PATH .. "data", env)(r, m, i, HORUS)
-- loadScript(FILE_PATH .. "build", env)()
loadScript(FILE_PATH .. "main", env)()
loadScript(FILE_PATH .. "game", env)()


if buildMode == nil then
	loadScript("/WIDGETS/SnakeHD/main", env)(true)
end

print("")
print("--------------------- COMPILE COMPLETE ---------------------")
print("")

return 0