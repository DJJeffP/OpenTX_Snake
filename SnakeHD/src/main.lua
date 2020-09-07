--[[
Snake HD
a Game made for the Radiomaster TX16S receiver
Made by: Jeffrey Postma
Inspired by Attila Toth for the Game script

- Original floor Snake 
- W = 20 * 8 = 160
- H = 11 * 8 = 88
- snake is 3px x 3px 
- every step it skips 1px
- rectangle box (playfield) = 171 x 99

TODO: 
- Menu for settings
- Mode 1 and Mode 2 selector default Mode 2
- Switch settings in menu
]]

local buildMode = ...
local VERSION = "1.0.0"
local FILE_PATH = "/SCRIPTS/TELEMETRY/SnakeHD/"
local SMLCD = LCD_W < 212
local HORUS = LCD_W >= 480
local FLASH = HORUS and WARNING_COLOR or 3
local env = "tc"
local ext = ".luac"

local ver, radio, maj, minor, rev = getVersion()

debug = false
direction = "right"
HighScore = 10

-- loadScript(FILE_PATH .. "conf" .. ext, env)(data)
loadScript(FILE_PATH .. "game" .. ext, env)(data)

function get_version()
	if debug then
		print("")
		print("--------------------- get_version ---------------------")
		print("")
	end

	print("version: "..ver)
 	if radio then 
		print ("radio: "..radio) 
	end
	if maj then 
  		print ("maj: "..maj) 
	end
	if minor then 
  		print ("minor: "..minor) 
	end
	if rev then 
		print ("rev: "..rev) 
	end
	return 1
end

function init()
	if debug then
		print("")
		print("--------------------- initialize ---------------------")
		print("")
	end

	get_version()

	lcd.clear()
    lcd.setColor(CUSTOM_COLOR, BLUE)
    lcd.drawFilledRectangle(0, 0, LCD_W + 2, LCD_H + 2, CUSTOM_COLOR)

	interval = 5
	add_bug()
end

function draw()
	game_draw()
	if state == GameStates.game_over then -- draw Game Over when the state is game_over
		if debug then
			print("Game Over!")
		end

		-- Display Score and Reset instruction
		lcd.clear()
		lcd.setColor(CUSTOM_COLOR, RED)
		lcd.drawFilledRectangle(0, 0, LCD_W + 2, LCD_H + 2, CUSTOM_COLOR)	
		lcd.drawRectangle(LCD_W/2-150, LCD_H/2-24, 280, 78,SOLID, 1)
		lcd.drawText(LCD_W/2-130, LCD_H/2+6, "Aileron Left or Right to Restart", 0)
		lcd.drawText(LCD_W/2-100, LCD_H/2+24,"Scrol to Change Speed", 0)

		if tail_lenght <= HighScore then
			lcd.drawText(LCD_W/2-52, LCD_H/2-20, "Score: ".. tail_lenght, 0)-- draw Score

			-- command to start another snake.  Aileron moved more than 20% Left or Right
			if math.abs(getValue("input2")) < -10 or math.abs(getValue("input2")) > 10 then
				game_restart()			
				return 0
			end
		elseif tail_lenght > HighScore then
			lcd.drawText(LCD_W/2-85, LCD_H/2-20, "NEW HIGHSCORE: ".. tail_lenght, 0) -- draw HighScore

			-- command to start another snake.  Aileron moved more than 20% Left or Right
			if math.abs(getValue("input2")) < -10 or math.abs(getValue("input2")) > 10 then
				HighScore = tail_lenght
				game_restart()
				return 0
			end
		end
	end
end


function run(event)
	if state == GameStates.running then
		interval = interval - 1
		if interval < 0 then
			game_update()
			if tail_lenght <= 15 then
				interval = 5
			elseif tail_lenght > 15 and tail_lenght <= 30 then
				interval = 4
			elseif tail_lenght > 30 and tail_lenght <= 45 then
				interval = 3
			elseif tail_lenght > 45 and tail_lenght <= 60 then
				interval = 2
			else
				interval = 1
			end
		end
	end

	-- ***************************************************************************
	--   Press Exit button to return to main screen
	-- ***************************************************************************
	local dir = direction

	if event == EVT_EXIT_BREAK then
		return 2
	elseif getValue('input1') > 100 and direction ~= "left" and state == GameStates.running then
		dir = "right"
		left, right, up, down = false, true, false, false
	elseif getValue('input1') < -100 and direction ~= "right" and state == GameStates.running then
		dir = "left"
		left, right, up, down = true, false, false, false
	elseif getValue('input2') > 100 and direction ~= "down" and state == GameStates.running then
		dir = "up"
		left, right, up, down = false, false, true, false
	elseif getValue('input2') < -100 and direction ~= "up" and state == GameStates.running then
		dir = "down"
		left, right, up, down = false, false, false, true
	elseif getValue('sa') > 100 then
		if state == GameStates.running then
			state = GameStates.pauze
			print( 'Game PAUZED!!' )
			return 0
		end
	elseif getValue('sa') < 0 then
		if state == GameStates.pauze then
			state = GameStates.running
			return 0
		end
	end
	direction = dir

	draw()
	return 0
end

return { run = run, init = init }