local path = ...
require(path .. ".libraries")
require(path .. ".game.spring")
require(path .. ".game.group")
require(path .. ".game.sound")
require(path .. ".game.physics")
require(path .. ".game.state")
require(path .. ".graphics.color")
require(path .. ".graphics.graphics")
require(path .. ".game.gameobject")

function engine_run(config)

   love.graphics.setDefaultFilter('nearest', 'nearest')
   local window_width, window_height = config.window_width, config.window_height
   local game_width, game_height = config.game_width, config.game_height
   pixel_size = window_width/game_width

   love.window.setTitle(config.game_name)
   love.graphics.setLineStyle(config.line_style or 'rough')
   if config.icon then love.window.setIcon(love.image.newImageData(config.icon)) end

   push:setupScreen(game_width,
                    game_height,
                    window_width,
                    window_height,
                    {fullscreen = false,
                    resizable = config.resize or false,
                    pixelperfect = config.pixel_perfect or false,
                    canvas = config.canvas or false,
                     msaa = 1})

   love.resize = function(w, h)
      push:resize(w, h)
   end

   get_global_mouse_pos = function()
      return push:toGame(love.mouse.getPosition())
   end

   get_mouse_pos = function()
      return love.mouse.getPosition()
   end

   init()

   if love.math then love.math.setRandomSeed(os.time()) end
   if love.timer then love.timer.step() end

   local dt = 0
   local fixed_dt = 1/60
   local accumulator = 0

   return function()
      if love.event then
           love.event.pump()
           for name, a, b, c, d, e, f in love.event.poll() do
               if name == 'quit' then
                   if not love.quit or not love.quit() then
                       return a or 0
                   end
               end
               love.handlers[name](a, b, c, d, e, f)
           end
      end

      if love.timer then
           love.timer.step()
           dt = love.timer.getDelta()
      end

      accumulator = accumulator + dt
      while accumulator >= fixed_dt do
           love.update(fixed_dt)
           accumulator = accumulator - fixed_dt
      end

      if love.graphics and love.graphics.isActive() then
           love.graphics.clear(love.graphics.getBackgroundColor())
           love.graphics.origin()
           love.draw()
           love.graphics.present()
      end

      if love.timer then love.timer.sleep(0.001) end
   end
end
