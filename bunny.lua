local SDL
local SDLImage
local SDLTtf

local window
local renderer
local bunnyImage
local bunnyTexture
local bunnyWidth
local bunnyHeight
local bunnies = {}
local running = true
local font
local textbox
local DELTA_TIME = math.floor( 1000 / 60 )
local ticks
local dTicks

local function addBunny()
	local w, h = window:getSize()
	return {
		x = math.random(w), y = math.random(h), 
		w = bunnyWidth, h = bunnyHeight, 
		ax = 0, ay = .0098, 
		vx = math.random(), vy = 0
	}
end

local function init()
	SDL = require'SDL'
	SDLImage = require'SDL.image'
	SDLTtf = require 'SDL.ttf'

	SDL.init{ SDL.flags.Video }
	SDLImage.init { SDLImage.flags.PNG }
	SDLTtf.init()

	window = SDL.createWindow{ 
		title = 'Bunnymark',
		width = 640,
		height = 480,
		flags = { SDL.window.Resizable }
	}


	renderer = SDL.createRenderer( window, -1 )

	renderer:setDrawColor( 0 )

	bunnyImage = SDLImage.load( 'bunny.png' )
	bunnyTexture = renderer:createTextureFromSurface( bunnyImage )
	
	_, _, bunnyWidth, bunnyHeight = bunnyTexture:query()

	bunnies[1] = addBunny()

	font = SDLTtf.open( 'DejaVuSans.ttf', 24 )
	ticks = SDL.getTicks()
	dTicks = 0
end

local function update( dt )
	local ww, wh = window:getSize()
	for i = 1, #bunnies do
		local bunny = bunnies[i]
		bunny.x = bunny.x + bunny.vx * dt
		bunny.y = bunny.y + bunny.vy * dt
		
		bunny.vx = bunny.vx + bunny.ax * dt
		bunny.vy = bunny.vy + bunny.ay * dt
		
		if (bunny.x >= ww and bunny.vx > 0) or (bunny.x <= 0 and bunny.vx < 0) then
			bunny.vx = -bunny.vx
		end

		if (bunny.y >= wh and bunny.vy > 0) or (bunny.y <= 0 and bunny.vy < 0) then
			bunny.vy = -bunny.vy
		end
	end
end

local textboxRect = {x = 0, y = 0, w = 100, h = 32}

local function draw( )
	renderer:clear()
	for i = 1, #bunnies do
		renderer:copy( bunnyTexture, nil, bunnies[i] )  
	end

--	local textbox = font:renderUtf8( ' FPS: ' .. math.floor(1000/ dTicks ) .. 'C: ' .. #bunnies , 'solid', 0xffffff )
--	local textboxTexture = renderer:createTextureFromSurface( textbox )
--	renderer:copy( textboxTexture, nil, textboxRect )
	print( 'FPS: ', math.floor( 1000/dTicks ), 'C:', #bunnies )

	renderer:present()
end

init()

while running do
	for e in SDL.pollEvent() do
		if e.type == SDL.event.quit then
			running = false
		elseif e.type == SDL.event.MouseButtonDown then
			local n = #bunnies * 2
			for i = #bunnies+1, n do
				bunnies[i] = addBunny()
			end
			print( 'Bunnies count', n )
		end
	end

	local newTicks = SDL.getTicks()
	dTicks = newTicks - ticks
	ticks = newTicks
	draw()
	update( dTicks )
	
	if dTicks <= DELTA_TIME then
		SDL.delay( DELTA_TIME )
	end
end
