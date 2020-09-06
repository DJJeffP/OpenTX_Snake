--[[
Snake HD
a Game made for the Radiomaster TX16S receiver
Made by: Jeffrey Postma
Inspired by Attila Toth for the Game script

- Original floor Snake gsm
- W = 20 * 8 = 160
- H = 11 * 8 = 88
- snake is 3px x 3px 
- every step it skips 1px
- rectangle box (playfield) = 171 x 99
]]


GameStates = { pause = 'pause', running = 'running', game_over = 'game_over' }
state = GameStates.running

-- Horus and TX16S
local LCD_W = 480
local LCD_H = 270

--[[
Gamefloor coordinates in px:
Upper Left: 34, 36
lower right: 378, 236,
]]


--GameBox
local GameFloorBox_W = 312
local GameFloorBox_H = 198
-- local GameFloorCenter_W = ((LCD_W / 2) - (GameFloorBox_W / 2))
-- local GameFloorCenter_H = ((LCD_H / 2) - (GameFloorBox_H / 2))

-- gamefloor
local floor_xMin = 34
local floor_xMax = 344
local floor_yMin = 36
local floor_yMax = 236

--gamefloor min and max
local xMin = math.floor( ( floor_xMin / 8 ) + 1)
local yMin = math.floor( ( floor_yMin / 8 ) + 1)
local xMax = math.floor( ( floor_xMax / 8 ) - 1)
local yMax = math.floor( ( floor_yMax / 8 ) - 1)

-- snake start coordinates
local snakeX = 16
local snakeY = 16

-- start direction
local dirX = 0
local dirY = 0

local SIZE = 8

local bugX = 0
local bugY = 0

local tail = {}
tail_lenght = 0

up = false
down = false
left = false
right = false

local bmap = lcd.drawBitmap
local icons = {}
  icons.bug = Bitmap.open("pics/bug.png")
  icons.snakehd = Bitmap.open("pics/snakehd.png")
  icons.nohead = Bitmap.open("pics/nohead.png")

function add_bug()
	if debug then
		print("")
		print("--------------------- add_bug ---------------------")
		print("")
	end

	-- bugX = math.random((LCD_W / 8) - 1)
	-- bugY = math.random((LCD_H / 8) - 1)
	bugX = math.random( ( xMin + 2 ), ( xMax ) - 2)
	bugY = math.random( ( yMin + 2 ), ( yMax ) - 2)
end

function game_draw()
	lcd.resetBacklightTimeout()
  	lcd.clear()
    lcd.setColor(CUSTOM_COLOR, BLUE)
    lcd.drawFilledRectangle(34, 36, GameFloorBox_W + 2, GameFloorBox_H + 2, CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR, GREY)
    lcd.drawRectangle(34, 36, GameFloorBox_W + 2, GameFloorBox_H + 2, CUSTOM_COLOR, 3)

	bmap(icons.snakehd, snakeX * SIZE,  snakeY * SIZE, 100) -- draw snake head

	for _, v in ipairs(tail) do
		bmap(icons.nohead, v[1] * SIZE,  v[2] * SIZE, 100) -- draw snake tail
	end

	bmap(icons.bug, bugX * SIZE,  bugY * SIZE, 100) -- draw bug

    lcd.setColor(CUSTOM_COLOR, BLUE)
    lcd.drawFilledRectangle(floor_xMax + 8, 36, 116, 200, CUSTOM_COLOR, 0)
    lcd.setColor(CUSTOM_COLOR, GREY)
    lcd.drawRectangle(floor_xMax + 8, 36, 116, 200, CUSTOM_COLOR, 3)
	lcd.drawText(floor_xMax+14, 76, "Score: ".. tail_lenght, SMLSIZE ) -- draw score
	lcd.drawText(floor_xMax+14, 100, "HighScore: ".. HighScore, SMLSIZE ) -- draw HighScore

	if tail_lenght <= 15 then
		lcd.drawText(floor_xMax+14, 40, "Level: 1", MIDSIZE ) -- draw Level
	elseif tail_lenght > 15 and tail_lenght <= 30 then
		lcd.drawText(floor_xMax+12, 36, "Level: 2", MIDSIZE ) -- draw Level
	elseif tail_lenght > 30 and tail_lenght <= 45 then
		lcd.drawText(floor_xMax+12, 36, "Level: 3", MIDSIZE ) -- draw Level
	elseif tail_lenght > 45 and tail_lenght <= 60 then
		lcd.drawText(floor_xMax+12, 36, "Level: 4", MIDSIZE ) -- draw Level
	else
		lcd.drawText(floor_xMax+12, 36, "Level: 5", MIDSIZE ) -- draw Level
	end
end

function game_update()
	if up and dirY == 0 then 
		dirX, dirY = 0, -1
	elseif down and dirY == 0 then
		dirX, dirY = 0, 1
	elseif left and dirX == 0 then
		dirX, dirY = -1, 0
	elseif right and dirX == 0 then
		dirX, dirY = 1, 0
	end

	local oldX = snakeX
	local oldY = snakeY

	snakeX = snakeX + dirX
	snakeY = snakeY + dirY

	if debug then
		print( 'Direction: '.. direction )
		print( 'snake coordinates: snakeX '.. snakeX .. ' snakeY ' .. snakeY )
	end

	if snakeX == bugX and snakeY == bugY then
		add_bug()
		tail_lenght = tail_lenght + 1
		table.insert(tail, {0,0})
	end

	if snakeX < xMin or snakeX > xMax then
    	state = GameStates.game_over
	elseif snakeY < yMin or snakeY > yMax then
		state = GameStates.game_over
	end

	if tail_lenght > 0 then
		for _, v in ipairs( tail ) do
			local x, y = v[1], v[2] -- following the (c=a, a=b, b=c) logic
			v[1], v[2] = oldX, oldY
			oldX, oldY = x, y
		end
	end

	for _, v in ipairs( tail ) do
		if snakeX == v[1] and snakeY == v[2] then
			state = GameStates.game_over
		end
	end
end

function game_restart()
	if debug then
		print("")
		print("--------------------- game_restart ---------------------")
		print("")
	end

	snakeX, snakeY = 16, 16
	dirX, dirY = 0, 0
	tail = {}
	up, down, left, right = false, false, false, false
	tail_lenght = 0
	state = GameStates.running
	add_bug()
end
