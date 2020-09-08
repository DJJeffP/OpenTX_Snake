--[[
Snake HD v2.1.0
a Game made for the Radiomaster TX16S receiver
Made by: Jeffrey Postma
Inspired by Attila Toth for the Game script

- Original floor Snake gsm
- W = 20 * 8 = 160
- H = 11 * 8 = 88
- snake is 3px x 3px 
- every step it skips 1px
- rectangle box (playfield) = 171 x 99

Play field grid = 310 x 200
Icons = 16 x 16



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

local SIZE = 16

-- gamefloor
local floor_xMin = 34
local floor_xMax = 344
local floor_yMin = 36
local floor_yMax = 236

--gamefloor min and max
local xMin = math.floor( ( floor_xMin / SIZE ) + 0)
local yMin = math.floor( ( floor_yMin / SIZE ) + 0)
local xMax = math.floor( ( floor_xMax / SIZE ) - 1)
local yMax = math.floor( ( floor_yMax / SIZE ) - 1)

-- snake start coordinates
local snakeX = 8
local snakeY = 8

-- start direction
local dirX = 0
local dirY = 0



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
  icons.yellow = Bitmap.open("pics/Image1_16x16.png")
  icons.pink = Bitmap.open("pics/Image2_16x16.png")
  icons.background = Bitmap.open("pics/snakehd_bg.png")
  icons.gameWindow = Bitmap.open("pics/snakehd_game_window.png")

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
	for _, v in ipairs( tail ) do
		if bugX == v[1] and bugY == v[2] then
			bugX = math.random( ( xMin + 2 ), ( xMax ) - 2)
			bugY = math.random( ( yMin + 2 ), ( yMax ) - 2)
			return 0
		end
	end
	
end

function game_draw()
	lcd.resetBacklightTimeout()
  	lcd.clear()
    lcd.setColor(CUSTOM_COLOR, BLUE)
    lcd.drawFilledRectangle(32, 32, GameFloorBox_W + 2, GameFloorBox_H + 2, CUSTOM_COLOR)
    bmap(icons.background, 0,  0, 100) -- draw background
    -- lcd.setColor(CUSTOM_COLOR, GREY)
    -- lcd.drawRectangle(34, 36, GameFloorBox_W + 2, GameFloorBox_H + 2, CUSTOM_COLOR, 3)
    bmap(icons.gameWindow, 32,  32, 100) -- draw game window

	bmap(icons.pink, snakeX * SIZE,  snakeY * SIZE, 100) -- draw snake head

	for _, v in ipairs(tail) do
		bmap(icons.pink, v[1] * SIZE,  v[2] * SIZE, 100) -- draw snake tail
	end

	bmap(icons.yellow, bugX * SIZE,  bugY * SIZE, 100) -- draw bug

    lcd.setColor(CUSTOM_COLOR, BLUE)
    lcd.drawFilledRectangle(floor_xMax + 8, 32, 112, 194, CUSTOM_COLOR, 0)
    lcd.setColor(CUSTOM_COLOR, 000460)
    lcd.drawRectangle(floor_xMax + 8, 32, 112, 194, CUSTOM_COLOR, 3)
    lcd.setColor(CUSTOM_COLOR, BLACK)
	lcd.drawText(floor_xMax+14, 76, "Score: ".. tail_lenght, SMLSIZE + CUSTOM_COLOR  + SHADOWED) -- draw score
	lcd.drawText(floor_xMax+14, 100, "HighScore: ".. HighScore, SMLSIZE  + CUSTOM_COLOR  + SHADOWED) -- draw HighScore
	lcd.setColor(CUSTOM_COLOR, RED)
	if tail_lenght <= 15 then
		lcd.drawText(floor_xMax+14, 40, "Level: 1", MIDSIZE  + CUSTOM_COLOR + SHADOWED) -- draw Level
	elseif tail_lenght > 15 and tail_lenght <= 30 then
		lcd.drawText(floor_xMax+12, 36, "Level: 2", MIDSIZE  + CUSTOM_COLOR ) -- draw Level
	elseif tail_lenght > 30 and tail_lenght <= 45 then
		lcd.drawText(floor_xMax+12, 36, "Level: 3", MIDSIZE  + CUSTOM_COLOR ) -- draw Level
	elseif tail_lenght > 45 and tail_lenght <= 60 then
		lcd.drawText(floor_xMax+12, 36, "Level: 4", MIDSIZE  + CUSTOM_COLOR ) -- draw Level
	else
		lcd.drawText(floor_xMax+12, 36, "Level: 5", MIDSIZE  + CUSTOM_COLOR ) -- draw Level
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

	if snakeX < xMin then
		snakeX = snakeX + 1
    	state = GameStates.game_over
    elseif snakeX > xMax then
		snakeX = snakeX - 1
    	state = GameStates.game_over
	elseif snakeY < yMin then
		snakeY = snakeY + 1
		state = GameStates.game_over
	elseif snakeY > yMax then
		snakeY = snakeY - 1
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

	snakeX, snakeY = 8, 8
	dirX, dirY = 0, 0
	tail = {}
	up, down, left, right = false, false, false, false
	tail_lenght = 0
	state = GameStates.running
	add_bug()
end
