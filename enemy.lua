Jumper = Class:extend()
Jumper:implement(GameObject)

function Jumper:new(args)
   self:init_game_obj(args)
   self.size = self.size or 10
   self.w, self.h = self.size or 10, 10
   self.class = 'Jumper'
   self.types = {
      'score',
      'lose',
      'buff',
   }
   self.gravity = self.gravity or 1
   if self.x < game_width/2 - 50 and self.x_vel < 0 then self.x_vel = math.abs(self.x_vel) end
   if self.x > game_width/2 - 50 and self.x_vel > 0 then self.x_vel = -math.abs(self.x_vel) end
   local chance = love.math.random(1, 100)
   if chance > 98 then
      self.type = 'buff'
   elseif chance > 50 then
      self.type = 'score'
   else
      self.type = 'lose'
   end


   if self.type == 'score' then
      self.color = assets.color_jumperscore
      self.points = self.size/4
   elseif self.type == 'lose' then
      self.color = assets.color_jumperlose
      self.points = -self.size/4
   elseif self.type == 'buff' then
      self.color = assets.color_jumperbonus
      self.points = '?'
   end

   if self.invincible then
      self.c = 1
      self.type = 'orb'
      self.points = ''
      self.x_vel, self.y_vel  = self.x_vel * 1.5, self.y_vel * 1.5
      self.timer:every(.1,  function()
         self.c = self.c + 1
         if self.c == 1 then
            self.color = assets.color_jumperlose
         elseif self.c == 2 then
            self.color = assets.color_jumperscore
         elseif self.c == 3 then
            self.color = assets.color_jumperbonus
         elseif self.c == 4 then
            self.color = assets.color_disker
            self.c = 1
         end

      end)
   end


   if type(self.points) == 'number' then self.points = math.floor(self.points) end
end

function Jumper:update(dt)
   self:update_game_obj(dt)
   self.y_vel = self.y_vel + 60 * self.gravity * dt
   if self.y_vel > 100 then self.y_vel = 100 end
   self.x = self.x + self.x_vel * dt
   self.y = self.y + self.y_vel * dt
   if self.y > game_height then
      self:die(false)
   end
end

function Jumper:draw()
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   love.graphics.setColor(0, 0, 0, .8)
   love.graphics.circle('fill', self.x, self.y + 2, self.size)
   graphics.circle(self.x, self.y, self.size, self.color, nil)
   love.graphics.setColor(1, 1, 1)
   graphics.print_centered(self.points, self.x, self.y, assets.secondary_font, assets.color_bg)
   love.graphics.setBlendMode('alpha')
   graphics.pop()
end

function Jumper:die(pk, combo, mute)
   self.remove = true
   local haspoints = type(self.points) == 'number'
   if pk then
      sfx.hit:play()
      for i = 1, 6 do
         Explosion{group = main.current.main, color = self.color, x = self.x,y = self.y, offset = self.size, pk = true}
      end
      if self.type == 'buff' then main.current.player:setbuff() end
   end
   if not pk then
      sfx.fall:play()
      main.current.cam:shake(10, .4, 10)
      main.current.spring:pull(.2 * love.math.random(-1, 1), 20, 2)
      if haspoints then self.points = math.floor(-self.points/2) end
      for i = 1, 4 do Explosion{group = main.current.main, color = self.color, x = self.x,y = self.y, offset = self.size, pk = false} end
   end
   if haspoints then
      local points = combo and combo > 1 and math.abs(self.points) or self.points
      if main.current.player.buff == '2XSCORE' then points = points * 2 end
      if main.current.player.buff == 'HALFSCORE' then points = math.floor(points/2) end

      if combo then if combo > 3 then points = math.floor(points * 1.5) elseif combo > 2 then points = math.floor(points * 1.2) end end

      local text = points > 0 and "+" ..points or points
      local y = pk and 0 or 20
      ScoreText{group = main.current.main, x = self.x, y = self.y - y, text = text, color2 = self.color}
      main.current.score:addscore(points)
   else
      if not pk then
         main.current.player:setbuff(true)
         local y = pk and 0 or 20
         ScoreText{group = main.current.main, x = self.x, y = self.y - y, text = 'CURSE', color2 = assets.color_disker}
         return
      end
      local y = pk and 0 or 20
      if self.type == 'orb' then
         main.current.player.invincible = true
         if not pk then main.current.player:spawn_powerup() end
         ScoreText{group = main.current.main, x = self.x, y = self.y - y, text = 'EPIC SHIELD', color2 = self.color}
         return
      end
      ScoreText{group = main.current.main, x = self.x, y = self.y - y, text = main.current.player.buff, color2 = self.color}
   end

end


Disker = Class:extend()
Disker:implement(GameObject)

function Disker:new(args)
   self:init_game_obj(args)
   self.size = self.size or 10
   self.w, self.h = 25, 25
   self.r = self.size
   self.color = assets.color_disker
   self.color2 = assets.color_bg
end

function Disker:update(dt)
   if self.y_vel > 100 then self.y_vel = 100 end
   self.x = self.x + self.x_vel * dt
   self.y = self.y + self.y_vel * dt
   self.angle = self.angle + 8 * dt
   if self.x < -100 or self.x > game_width + 100 then self:destroy() end

   self:check_col()

end

function Disker:check_col()
   local rectx, recty, rw, rh = self.x - self.size, self.y - self.size, self.size * 2, self.size * 2
   local player = main.current.player
   if player.x > rectx and player.x < rectx + rw and player.y > recty and player.y < recty + rh then
      local invincible = player:die(sign(self.x_vel))
      if invincible then self:destroy() self:explode() end
   end
end


function Disker:destroy()
   self.remove = true
end

function Disker:explode()
   main.current.cam:shake(12, .5,  30)
   sfx.death2:play()
   local ydir = self.y > game_height/2 and -1 or 1
   Dust{group = main.current.main, x = self.x, y = self.y + 4 * ydir, x_vel = 0, y_vel = 0, radius = 30, special = true, color = assets.color_disker}
end

function Disker:draw()
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   graphics.rectangle(self.x, self.y, self.w, self.h, 3, 3, self.color)
   graphics.pop()

end



Powerup = Class:extend()
Powerup:implement(GameObject)

function Powerup:new(args)
   self:init_game_obj(args)
   self.size = self.size or 5
   self.r = self.size
   self.color = assets.color_jumperbonus
   self.t = 0
   Dust{group = main.current.main, x = self.x, y = self.y, x_vel = 0, y_vel = 0, radius = 12, special = true, color = self.color}
   sfx.powerup2:play()
end

function Powerup:update(dt)
   self.t = self.t + dt * 3
   self.y = self.y + math.sin(self.t) * .1
   self:check_col()
end

function Powerup:draw()
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   graphics.circle(self.x, self.y + 1, self.r, assets.color_bg)
   graphics.circle(self.x, self.y, self.r, self.color)
   -- for i = 1, 4 do
   --    graphics.arc('open', self.x, self.y, self.r - 1.2, (i-1) * math.pi/2 + math.pi/4 - math.pi/6, (i-1) * math.pi/2 + math.pi/4 + math.pi/6, self.color2, 3)
   -- end
   graphics.pop()
end


function Powerup:check_col()
   local rectx, recty, rw, rh = self.x - self.size, self.y - self.size*2, self.size * 2, self.size * 5
   local player = main.current.player
   if player.x > rectx and player.x < rectx + rw and player.y > recty and player.y < recty + rh then
      player:setrandompower()
      self:die()
   end
end

function Powerup:die()
   self.remove = true
   local y = self.y > game_height/2 and 20 or - 20
   ScoreText{group = main.current.main, x = self.x, y = self.y - y, text = main.current.player.power, color2 = self.color, duration = 1.5, switchg = y == -20}
   Dust{group = main.current.main, x = self.x, y = self.y, x_vel = 0, y_vel = 0, radius = 12, special = true, color = self.color}
end


Explosion = Class:extend()
Explosion:implement(GameObject)


function Explosion:new(args)
   self:init_game_obj(args)
   if self.pk then
      self.x_vel, self.y_vel = randomdir(-1, 1), randomdir(-1, 1)
      self.x_vel, self.y_vel =  vector2:normalize(self.x_vel, self.y_vel)
      self.speed = randomdir(50, 140)
   else
      self.x_vel, self.y_vel = randomdir(-1, 1), randomdir(-.5, -1)
      self.x_vel, self.y_vel =  vector2:normalize(self.x_vel, self.y_vel)
      self.speed = randomdir(150, 200)
   end

   self.color = self.color or assets.color_effects
   self.angle = math.atan2(self.y_vel, self.x_vel)
   self.x, self.y = self.x + self.x_vel * self.offset, self.y + self.y_vel * self.offset
   self.w,  self.h = 10, 3
   self.timer:after(.1, function() self.timer:tween(.3, self, {w = 0}, 'out-cubic') end)
end

function Explosion:update(dt)
   self:update_game_obj(dt)
   if self.w < 2 then self.remove = true end
   self.x = self.x + self.x_vel * self.speed * dt
   self.y = self.y + self.y_vel * self.speed * dt

end

function Explosion:draw()
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   graphics.rectangle(self.x, self.y, self.w, self.h,  3, 3,  self.color)
   graphics.pop()
end


function math.remap(v, old_min, old_max, new_min, new_max)
  return ((v - old_min)/(old_max - old_min))*(new_max - new_min) + new_min
end
