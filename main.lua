web = true
require 'engine'
require 'assets'
require 'player'
require 'score'
require 'arena'
require 'enemy'
require 'effects'

window_width, window_height = 768, 768
game_width, game_height = 256, 256

-- window_width, window_height = love.graphics.getWidth(), love.graphics.getHeight()


time_scale = 1
global_dt = 0
highest_score = 0


function init()
   first_time = true
   local save, errormsg = nil, nil
   if not web then save, errormsg = love.filesystem.load("save.lua") end
   if not errormsg and not web then
      local data = save()
      highest_score = data.high_score
      sfx_volume = data.sfx_volume
      update_volume()
   end
   main = Main()
   main_canvas = love.graphics.newCanvas(game_width, game_height)
   main:add(Arena('Level1'))
   main:goto('Level1')
   love.window.setMode(window_width, window_height)

   input = Input()
	input:bind('c', 'select')
	input:bind('c', 'restart')
   input:bind('x', 'attack')
   input:bind('f', 'fullscreen')
   -- input:bind('mouse1', 'attack')
   input:bind('c', 'skill')
   input:bind('down', 'down')
   input:bind('up', 'up')
   input:bind('v', 'test')
end

function love.update(dt)
   global_dt = dt
   if input:pressed('fullscreen') then
      push:switchFullscreen()
   end

   if main then main:update(dt * time_scale) end

end

function love.draw()
   push:start()
   -- love.graphics.setCanvas(main_canvas)
   -- love.graphics.clear()
   -- love.graphics.setColor(1, 1, 1)
   if main then main:draw() end
   -- love.graphics.setCanvas()
   --
   -- love.graphics.setColor(255, 255, 255, 255)
   -- love.graphics.setBlendMode('alpha', 'premultiplied')
   -- love.graphics.draw(main_canvas, 0, window_height/2 - window_width/2, 0, pixel_size, pixel_size)
   -- love.graphics.setBlendMode('alpha')
   push:finish()

	--debuggggg
   if show_fps then love.graphics.print(love.timer.getFPS(), 10, 10, 0, 3, 3) end

end


function love.quit()
   love.filesystem.write("save.lua", "data = {} data.high_score = " .. highest_score .. " data.sfx_volume = " .. sfx_volume .. " return data")
end

function love.run()
	return engine_run({
		game_width = game_width,
		game_height = game_height,
		window_width = window_width,
		window_height = window_height,
		game_name = 'SL1CRX',
		canvas = true,
      pixel_perfect = false,
      resizable = true,
      icon = 'assets/images/icon.png'
	})
end
