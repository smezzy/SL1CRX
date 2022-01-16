Arena = Class:extend()
Arena:implement(State)

function Arena:new(name)
   self:init_state(name)
end

function Arena:on_enter(from)
   time_scale = 1
   self.timer = Timer()
   self.main = Group()
   self.walls = Group()
   self.spring = Spring(0, 70, 10)
   self.angle = 0
   self.cam = Camera(game_width/pixel_size, game_height/pixel_size, game_width, game_height)
   self.player = nil
   self.persistent_draw = false
   self.persistent_update = false
   self.map = sti("assets/levels/level1.lua")
   self.score = Score()
   self.shaker = Spring()
   self.tutorial_t = 0
   self.cam.x, self.cam.y = game_width/2,game_height/2

   -- self.l_wall = Wall{group = main.current.walls, x = 0, y = 0, w = 16, h = game_height}
   -- self.r_wall = Wall{group = main.current.walls, x = game_width - 16, y = 0, w = 16, h = game_height}
   -- self.up_wall = Wall{group = main.current.walls, x = 0, y = 0, w = game_width, h = 16}
   -- self.down_wall = Wall{group = main.current.walls, x = 0, y = game_height - 16, w = game_width, h = 16}

   self.has_started = false
   self.player = Player{group = self.main, x = game_width/2, y = game_height - 16, x_vel = 0}
   self.player.can_move = false
   self.player.draw_attack = false
   self.volumetext = nil
   if not first_time then self:start() end
end

function Arena:start()
   if first_time then
      ost = sfx.ost:play() first_time = false
      self.timer:after(.07, function() self.player:attack() end)
      self.player:attack()
      self.player.x_vel = -1
   else
      self.player.x_vel = 1
   end

   self.player.can_move = true
   self.has_started = true
   self.player.draw_attack = true
   self.timer:every(3, function()  Jumper{group = main.current.main, y_vel = -150, x_vel =  randomdir(-30, 30), x = randomdir(0, game_width), y = game_height, size = love.math.random(10,  20)} end)
   self.timer:every(5, function()  Jumper{group = main.current.main, y_vel = -150, x_vel =  randomdir(-30, 30), x = randomdir(0, game_width), y = game_height, size = love.math.random(10,  20) } end)
   self.timer:every(2, function()  Jumper{group = main.current.main, y_vel = -20, x_vel = 35, x = 0, y = randomdir(20, game_height - 60) , size = love.math.random(10,  20)} end)
   self.timer:every(3, function()  Jumper{group = main.current.main, y_vel = -20, x_vel = -35, x = game_width, y = randomdir(20, game_height - 60) , size = love.math.random(10,  20)} end)

   -- self.timer:every(3, function()  Disker{group = main.current.main, y_vel = 0, x_vel = -100, x = game_width, y = randomdir(50, game_height - 50), size = love.math.random(10,  20)} end)
   -- self.timer:every(7, function()  Disker{group = main.current.main, y_vel = 0, x_vel = -100, x = game_width, y = randomdir(50, game_height - 50), size = love.math.random(10,  20)} end)
   -- self.timer:every(3, function()  Disker{group = main.current.main, y_vel = 0, x_vel = 100, x = 0, y = randomdir(50, game_height - 50), size = love.math.random(10,  20)} end)
   self.disker_min, self.disker_max = 3, 9
   self.disker_velocity = 120
   self:spawn_disker()
   self.angleoffset = 0
   self.sx, self.sy = 1, 1
   self.active_waves = ''
end

function Arena:on_exit()
   self.player = nil
   self.main = nil
   self.walls = nil
   self.score = nil
   self.cam = nil
   -- self.l_wall, self.r_wall, self.up_wall, self.down_wall = nil
   self.timer = nil
   self = nil
   return true
end


function Arena:update(dt)
   if self.timer then self.timer:update(dt) end
   self.tutorial_t = self.tutorial_t + dt * 10
   self.shaker:update(dt)
   self.main:update(dt)
   self.cam:update(dt)
   self.score:update(dt)
   self.spring:update(dt)
   self.walls:update(dt)
   if math.abs(self.spring.x) < 0.0005 then self.spring.x = 0 end
   if input:pressed('down') then
      if self.volumetext then self.volumetext.remove = true end
      sfx_volume = sfx_volume - 0.1
      if sfx_volume < 0.1  then sfx_volume = 0.1 end
      self.volumetext = SimpleText{group = main.current.main, x = game_width/2, y = 40, text = "VOLUME: " ..sfx_volume}
      update_volume()
   end
   if input:pressed('up') then
      if self.volumetext then self.volumetext.remove = true end
      sfx_volume = sfx_volume + 0.1
      if sfx_volume > 1  then sfx_volume = 1 end
      self.volumetext = SimpleText{group = main.current.main, x = game_width/2, y = 40, text = "VOLUME: " ..sfx_volume}
      update_volume()
   end

   if not self.has_started and input:pressed('attack') then self:start() end
end

function Arena:activate_wave(id)
   if string.find(self.active_waves, id) then return end
   if id == 'C' then
      self.active_waves = self.active_waves .. 'C'
      self:spawn_powerup()
   end
   if id == 'A' then
      self.active_waves = self.active_waves .. 'A'

      self.timer:every(35, function()

         self.timer:every(.25, function()
            Jumper{group = main.current.main, y_vel = -280, x_vel = 45, x = 40, y = game_height, size = love.math.random(10,  20), gravity = 3}
         end, 2)
         self.timer:every(.25, function()
            Jumper{group = main.current.main, y_vel = -280, x_vel = -45, x = game_width - 40, y = game_height, size = love.math.random(10,  20), gravity = 3}
         end, 2)
      end)
   elseif id == 'B' then
      self.active_waves = self.active_waves .. 'B'

      self.timer:every(75, function()
         DangerWarning{group = main.current.walls, color = assets.color_jumperscore}
         self.timer:after(.8, function()
            self.timer:every(.2, function()
               Jumper{group = main.current.main, y_vel = -55, x_vel = love.math.random(125, 175), x = 0, y = randomdir(20, game_height - 70) , size = love.math.random(10,  20), gravity = 4}
            end, 2)
            self.timer:every(.2, function()
               Jumper{group = main.current.main, y_vel = -55, x_vel = love.math.random(-125, -175), x = game_height, y = randomdir(20, game_height - 70) , size = love.math.random(10,  20), gravity = 4}
            end, 2)
            self.timer:every(.2, function()
               Jumper{group = main.current.main, x_vel = love.math.random(-20, 20), y_vel = -275, x = love.math.random(game_width/2 - 30, game_width/2 + 30), y = game_width , size = love.math.random(10,  20),  gravity = 10}
            end, 2)
         end)
      end)
   end
end

function Arena:draw()
   -- love.graphics.push()
   -- love.graphics.translate(0, 16)
   graphics.push(game_width/2, game_height/2, self.angle + self.spring.x, self.sx, self.sy)
   self.cam:attach()
   self.map:drawLayer(self.map.layers["Camada de Tiles 1"])
   self.main:draw()
   self.map:drawLayer(self.map.layers["background"])
   -- self.walls:draw()
   graphics.push(game_width/2, game_height/2, math.cos(self.tutorial_t) * 0.03, 1, 1)
   if not self.has_started then
      graphics.print_centered('X -> ATTACK', game_width/2, game_height/2 - 30, assets.main_font, assets.color_jumperscore)
      graphics.print_centered('C -> USE SKILL', game_width/2, game_height/2 - 10, assets.main_font, assets.color_jumperbonus)
      graphics.print_centered('F -> SWITCH FULLSCREEN', game_width/2, game_height/2 + 10, assets.main_font, assets.color_jumperbonus)
      graphics.print_centered('UP / DOWN ->  VOLUME', game_width/2, game_height/2 + 30, assets.main_font, assets.color_jumperbonus)
   end
   graphics.pop()
   -- self.map:bump_draw()
   self.walls:draw()
   self.score:draw()
   self.cam:detach()
   graphics.pop()
   -- love.graphics.pop()
end

function Arena:spawn_disker()

   if self.score.points > 300 then self.disker_max = 5 end
   if self.score.points > 500 then self.disker_max = 3 end
   if self.score.points > 600 then self.disker_velocity = 150 end


   self.timer:after(love.math.random(self.disker_min, self.disker_max), function()
      local pos = 0
      -- if self.player.x_vel > 0 then
      --    pos = -1
      -- else
      --    pos = game_width
      -- end
      if self.player.x_vel > 0 then
         pos = -1
      else
         pos = game_width
      end
      Disker{group = main.current.main, x = pos, y = self.player.y, x_vel = sign(pos) * -self.disker_velocity, y_vel = 0}
      self:spawn_disker()

      if self.score.points < 750 then return end

      if pos == game_width then
         pos = -1
      else
         pos = game_width
      end

      Disker{group = main.current.main, x = pos, y = self.player.y, x_vel = sign(pos) * -self.disker_velocity, y_vel = 0}


   end)

   if self.score.points < 200 then return end
   self.timer:after(love.math.random(self.disker_min + 3, self.disker_max + 4), function()
      local pos = 0
      -- if self.player.x_vel > 0 then
      --    pos = -1
      -- else
      --    pos = game_width
      -- end
      if self.player.x_vel > 0 then
         pos = -1
      else
         pos = game_width
      end

      Disker{group = main.current.main, x = pos, y = self.player.y, x_vel = sign(pos) * -self.disker_velocity, y_vel = 0}

      if self.score.points < 550 then return end
      self.timer:after(love.math.random(2, 3), function()
         local pos = 0
         -- if self.player.x_vel > 0 then
         --    pos = -1
         -- else
         --    pos = game_width
         -- end
         if self.player.x > game_width/2 then
            pos = -1
         else
            pos = game_width
         end
         Disker{group = main.current.main, x = pos, y = self.player.y, x_vel = sign(pos) * -self.disker_velocity, y_vel = 0}

      end)

   end)




end

function Arena:spawn_powerup()
   local posx = love.math.random(20, game_width - 20)
   local posy = 0
   if self.player.y < game_height/2 then posy = 22 else posy = game_height - 22 end

   self.timer:after(love.math.random(3, 6), function() Powerup{group = main.current.main, x = posx, y = posy} end)
end


Wall = Class:extend()
Wall:implement(GameObject)

function Wall:new(args)
   self:init_game_obj(args)
   self.class = "Wall"
   self.color = assets.color_walls
   -- main.current.world:add(self, self.x, self.y, w or self.w, h or self.h)
end

function Wall:update(dt)

end

function Wall:draw()
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   graphics.rectangle2(self.x, self.y, self.w, self.h, 0, 0, self.color)
   graphics.pop()
end


DangerWarning = Class:extend()
DangerWarning:implement(GameObject)

function DangerWarning:new(args)
   self:init_game_obj(args)
   self.class = "DangerWarning"
   self.color = self.color or assets.color_disker
   self.switch = false
   self.timer:every(.2, function() self.switch = not self.switch self.color = self.switch and assets.color_bg or assets.color_jumperscore end, 3)
   self.timer:after(.6, function() self.remove = true end)
end

function DangerWarning:update(dt)
   self:update_game_obj(dt)

end

function DangerWarning:draw()
   -- graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   graphics.rectangle2(8, 10, game_width - 16 , game_height - 16, 1, 1, self.color, 3)
   -- graphics.pop()
end
