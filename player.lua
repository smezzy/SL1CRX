Player = Class:extend()
Player:implement(GameObject)

function Player:new(args)
   -- game object
   self:init_game_obj(args)
   self.class = 'Player'
   self.color = Color(.6, .6, .6, .2)
   self.color2 = Color("#2b2b2b")
   self.cam = main.current.cam

   self.w, self.h = 32, 32
   self.x_vel, self.y_vel = self.x_vel or 1, 0
   self.angle = 0
   self.ox, self.oy = 16, 14
   self.sx = 1
   --player variables
   self.flipx = false
   self.grounded = false
   self.charge_jump = 0
   self.is_jumping = false
   self.can_move =  true
   self.can_die = true
   self.draw_attack = true
   self.move_speed = 150
   self.default_move_speed = 150
   self.buff = 'NOBUFF'
   self.pbuff = 'NOBUFF'
   self.invincible = false
   self.buffs = {
      '2XSCORE',
      'SLOW',
      'FAST',
   }

   self.power = 'NOPOWER'


   self.timer_special = Timer()

   --sprites
   self.runsheet = love.graphics.newImage('assets/images/playersheet.png')
   local g = anim8.newGrid(32, 32, self.runsheet:getWidth(), self.runsheet:getHeight())
   self.run = anim8.newAnimation(g('1-4', 1), 0.05)
   self.runleft = self.run:clone():flipH()

   self.curr_side = 'down'
   self.timer:every(.15, function()
      if self.can_move then
         local ydir = self.y > game_height/2 and -1 or 1
         for i = 1, 4 do Dust{group = main.current.main, x = self.x, y = self.y - 2 * ydir, x_vel = sign(self.x_vel) * randomdir(-30, -20), y_vel = ydir * randomdir(15, 25), radius = randomdir(3, 5)} end

      end
   end)
end


function Player:update(dt)
   self:update_game_obj(dt)
   self.timer_special:update(global_dt)
   if self.dead then
      time_scale = time_scale - global_dt * 2
      self.x = self.x + self.x_vel * dt
      self.angle = self.angle + self.rot_vel * dt
      self.y = self.y + self.y_vel * dt
      self.y_vel = self.y_vel + 1000 * dt
      if time_scale < 0.1 then time_scale = 0.1 end
      if input:pressed('restart') then
         main:goto('Level1')
      end
      return
   end
   if input:pressed('skill') then
      if self.power == 'JUDGMENT NUT' then
         self:JUDGMENTNUT()
         self.power = 'NOPOWER'
         self.timer:after(love.math.random(10,20),function() main.current:spawn_powerup() end)
      elseif self.power == 'DOPPELGANGER' then
         self:doppelganger()
         self.power = 'NOPOWER'
         self.timer:after(15, function() main.current:spawn_powerup() end)
      else
         sfx.fail:play()
      end
   end

   if not self.can_move then return end

   if input:pressed('attack') then
      self:attack()
   end

   self:move(dt)
end


function Player:attack()
   sfx.slice:play()
   self.flipx = not self.flipx
   self.x_vel = self.x_vel * -1
   local prevx, prevy = self.x, self.y
   if self.curr_side == 'down' then
      self.y = 0 + 16
      self.sy = -1
      self.curr_side = 'up'
   elseif self.curr_side == 'up' then
      self.y = game_height - 16
      self.sy = 1
      self.curr_side = 'down'
   end
   Slice{group = main.current.main, p1x = prevx, p1y = prevy, p2x = self.x, p2y = self.y}
   local hits = main.current.main:query_line(self.x, 20)
   local dhit = {}
   if self.doppelganger_clone then dhit = main.current.main:query_line(self.doppelganger_clone.x, 20) end

   if self.doppelganger_clone then
      self.doppelganger_clone:attack()
      for _, obj in ipairs(dhit) do
         if #hits > 0 then
            for _, pobj in ipairs(hits) do
               if  obj.id == pobj.id then
                  break
               else
                  table.insert(hits, obj)
                  break
               end
            end
         else
            table.insert(hits, obj)
         end
      end
   end

   local combo = #hits

   for _, e in ipairs(hits) do
      e:die(true, combo)
      HitCircle{group = main.current.main, x = e.x, y = e.y, radius = 10 + (#hits - 1) * 5}
      self.cam:shake(6 + #hits -1, .2, 40, 'Y')
      for i = 1, 10 * #hits/2 do
         Sparks{group = main.current.main, x = e.x, y = e.y}
      end
   end


   if #hits > 1 then
      sfx.combo:play()
      local text = ""
      local h = #hits
      local color = nil
      if h == 2 then
         text = "DOUBLE SLICE!"
         color = assets.color_jumperbonus
      elseif h == 3 then
         text = "OH BABYYY A TRIPLE!!"
         color = assets.color_jumperscore
         if not web then sfx.triple:play() end
      elseif h >= 4 then
         color = assets.color_disker
         if not web then sfx.ohgod:play() end
         text = "OH MY GOD! OH MY FUCKING GOD!!!"
      end
      ComboText{group = main.current.main, text = text, color2 = color, force = h}
   end
   local ydir = self.y > game_height/2 and -1 or 1
   for i = 1, 12 do Dust{group = main.current.main, x = self.x, y = self.y - 2 * ydir, x_vel = love.math.random(-150, 150), y_vel = ydir * randomdir(20, 35), radius = randomdir(4, 6)} end
end

function Player:move(dt)
   -- self.angle = self.angle + dt * 3
   self.run:update(dt)
   self.runleft:update(dt)

   if self.buff == 'SLOW' then
      self.move_speed = 120
   elseif self.buff == 'FAST' then
      self.move_speed = 180
   else
      self.move_speed = self.default_move_speed
   end

   self.x = self.x + self.x_vel * self.move_speed * dt

   if self.x_vel < 0 and self.x < 16 then
      self.x = 20
      self.x_vel = self.x_vel * -1
      self.flipx = not self.flipx
   end
   if self.x_vel > 0 and self.x > game_width - 24 then
      self.x_vel = self.x_vel * -1
      self.x = game_width - 20
      self.flipx = not self.flipx
   end
   -- main.current.angleoffset = lerp(-0.02, 0.02, self.x/game_width)

end


function Player:draw()
   if self.hidden then return end
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   if self.invincible then graphics.circle(self.x - bool_to_int(self.flipx), self.y - 5, 9, assets.color_jumperscore, 1) end
   if self.draw_attack then graphics.polyline(self.color, self.lw, self.x + .5, self.y - 16, self.x, self.y - game_height) end
   if not self.flipx then
      self.run:draw(self.runsheet, self.x - self.w/2, self.y - self.h/2 + 8 - self.oy)
   else
      self.runleft:draw(self.runsheet, self.x - self.w/2, self.y - self.h/2 + 8 - self.oy)
   end
   graphics.pop()
   -- love.graphics.circle("fill", self.x, self.y, 2)

end

function Player:setbuff(debuff)
   if debuff then
      self.buff = 'HALFSCORE'
   else
      self.pbuff = self.buff
      self.buff = self.buffs[love.math.random(1, #self.buffs)]
   end
   self.timer:after(8, function() self:remove_buff() end)
end


function Player:setrandompower()
   local chance = love.math.random(1, 100)
   sfx.powerup:play()
   if chance > 50 then
      self.power = 'JUDGMENT NUT'
   else
      self.power = 'DOPPELGANGER'
   end
end

function Player:remove_buff()
   if self.buff ~= self.pbuff then self.buff = 'NOBUFF' end
end
function Player:spawn_shield()
   self.shield_handle = self.timer:after(love.math.random(40, 50), function()
      Jumper{group = main.current.main, y_vel = love.math.random(-230, -280), x_vel = love.math.random(50, -50), x = love.math.random(0, game_width), y = game_height, size = 10, gravity = 7, invincible = true}
   end)
end


function Player:die(dir)
   if self.shield_handle then self.timer:cancel(self.shield_handle) end
   if not self.can_die then return end
   if self.dead then return end
   if self.invincible then
      self.invincible = false
      self:spawn_shield()
      return true
   end
   self.can_move = false
   self.draw_attack = false
   self.y_vel = self.curr_side == 'down' and -320 or 0
   self.rot_vel = randomdir(18, 27)
   self.x_vel = 10 * dir
   self.dead = true
   self.cam:shake(8, 1,  70)
   sfx.death:play()
   local ydir = self.y > game_height/2 and -1 or 1
   Dust{group = main.current.main, x = self.x, y = self.y + 4 * ydir, x_vel = 0, y_vel = 0, radius = 40, special = true}

   if main.current.score.points > highest_score then highest_score = main.current.score.points end

   self.timer:after(.2, function() ComboText{group = main.current.main, text = '...DEAD...', color2 = assets.color_disker, sx = 2, sy = 2, force = 4, special = true} end)
   local brabo = nil
   self.timer:after(.2, function() brabo = ComboText{group = main.current.main, text = 'Highest score: ' ..highest_score, color2 = assets.color_jumperscore, force = 4, special = true, yy = game_height/2 + 30} end)
   self.timer:after(.4, function() ComboText{group = main.current.main, text = "'c' to restart", color2 = assets.color_effects, force = 4, special = true, yy = game_height/2 - 30, t = brabo.t} end)
   sfx.death2:play()
end


function Player:check_collisions(cols)
   for _, col in ipairs(cols) do
      if col.normal.y < 0 then
         self.y_vel = 0
         self.grounded = true
         self.is_jumping = false
      end
   end
end


function Player:doppelganger()
   if self.doppelganger_clone then return end
   local diff = self.x - game_width/2
   local ydir = self.y > game_height/2 and -1 or 1
   -- local ypos = self.curr_side == 'down' and self.y or 16
   self.doppelganger_clone = Doppelganger{group = main.current.main, x = game_width/2 - diff, y = self.y, x_vel = -self.x_vel, flipx = not self.flipx, player = self, curr_side =  self.curr_side, sy = self.sy}
   Dust{group = main.current.main, x = self.doppelganger_clone.x, y = self.doppelganger_clone.y + 4 * ydir, x_vel = 0, y_vel = 0, radius = 12, special = true, color = assets.color_jumperbonus, follow = self.doppelganger_clone, ydiff = ydir * 4}
   self.timer:after(15, function() if self.doppelganger_clone then self.doppelganger_clone:die() end end)
end


function Player:JUDGMENTNUT()
   time_scale = 0.1
   local slices = {}
   self.timer_special:tween(.8, main.current, {sx = 1.1, sy = 1.1})
   if not web then
      self.timer_special:tween(.8, ost, {pitch = .5}, 'linear')
   else
      self.pitcht = 1
      self.timer_special:every(0.02, function()
         self.pitcht = self.pitcht - 0.02
         if self.pitcht <= 0.1 then self.pitcht = 0.1 end
         ost:setPitch(self.pitcht)
      end, 20)
   end

   self.cam:shake(6, 2, 60)
   sfx.scum:play()
   self.can_die = false

   self.hidden = true
   Dust{group = main.current.main,  x_vel = 200, y_vel = 0, x = self.x, y = self.y, radius = randomdir(5,7)}
   Dust{group = main.current.main,  x_vel = 0, y_vel = 200, x = self.x, y = self.y, radius = randomdir(5,7)}
   Dust{group = main.current.main,  x_vel = 0, y_vel = -200, x = self.x, y = self.y, radius = randomdir(5,7)}
   Dust{group = main.current.main,  x_vel = -200, y_vel = 0, x = self.x, y = self.y, radius = randomdir(5,7)}
   Dust{group = main.current.main,  x_vel = -200, y_vel = -150, x = self.x, y = self.y, radius = randomdir(5,7)}
   Dust{group = main.current.main,  x_vel = 200, y_vel = -150, x = self.x, y = self.y, radius = randomdir(5,7)}

   self.timer_special:after(.5, function()


      create_line = function(extra)
         local chance = love.math.random(0, 100)
         if chance > 75 then
            local x1, y1 = love.math.random(0, game_width), 0
            local x2, y2 = love.math.random(0, game_width), game_height
            s = Slice{group = main.current.main, p1x = x1, p1y = y1, p2x = x2, p2y = y2, nut = true}
            if not extra then table.insert(slices, s) end
         elseif chance > 50 then
            local x1, y1 = 0, love.math.random(0, game_height)
            local x2, y2 = game_width, love.math.random(0, game_height)
            s = Slice{group = main.current.main, p1x = x1, p1y = y1, p2x = x2, p2y = y2, nut = true}
            if not extra then table.insert(slices, s) end
         elseif chance > 25  then
            local x1, y1 = game_width, love.math.random(0, game_height)
            local x2, y2 = 0, love.math.random(0, game_height)
            s = Slice{group = main.current.main, p1x = x1, p1y = y1, p2x = x2, p2y = y2, nut = true}
            if not extra then table.insert(slices, s) end
         else
            local x1, y1 = love.math.random(0, game_width), game_height
            local x2, y2 = love.math.random(0, game_width), 0
            s = Slice{group = main.current.main, p1x = x1, p1y = y1, p2x = x2, p2y = y2, nut = true}
            if not extra then table.insert(slices, s) end
         end
      end
      self.timer_special:every(.04, function() create_line() sfx.slice:play() end, 20)
      self.timer_special:every(.04, function() create_line(true) end, 20)
   end)

   self.timer_special:after(2, function()
      self.hidden = false
      sfx.slice:play()
      sfx.combo:play()
      for _, s in ipairs(slices) do
         s:drawnut()
         time_scale = 1
      end
      local hits = 0
      for _, e in ipairs(main.current.main.objects) do
         if e:is(Jumper) or e:is(Disker) then
            if e:is(Jumper) then e:die(true, 3) else e:destroy() end
            hits = hits + 1
            sfx.hit:play()
            HitCircle{group = main.current.main, x = e.x, y = e.y, radius = 15}
            for i = 1, 20 do
               Sparks{group = main.current.main, x = e.x, y = e.y}
            end
         end
      end

      self.timer:after(.1, function() self.can_die = true end)

      if hits >= 4 then sfx.horns:play() ComboText{group = main.current.main, text = 'SMOKIN SEXY STYLE!!', color2 = assets.color_disker, force = 6, duration = 2, sx = 1.2, sy = 1.2} end

      self.cam:shake(6, .2, 40)

      self.timer_special:tween(.2, main.current, {sx = 1, sy = 1}, 'out-cubic')
      if not web then self.timer_special:tween(.5, ost, {pitch = 1}, 'linear') else ost:setPitch(1) end
   end)
end


Slice = Class:extend()
Slice:implement(GameObject)

function Slice:new(args)
   self:init_game_obj(args)
   self.color = assets.color_effects
   self.lw = 6

   if self.nut then
      self._p1x, self._p1y = self.p1x, self.p1y
      self.timer:tween(.2, self, {p1x = self.p2x, p1y = self.p2y}, 'linear')
      self.lw = 2
      return
   end
   self.timer:tween(.3, self, {p1y = self.p2y}, 'linear')
   self.timer:tween(.3, self, {lw = -1}, 'out-cubic')
end

function Slice:update(dt)
   if self.nut then self:update_game_obj(global_dt) else self:update_game_obj(global_dt) end
   if self.lw < 0.6 then self.remove = true end
end

function Slice:draw()
   graphics.polyline(self.color, self.lw, self.p1x, self.p1y, self.p2x, self.p2y)
end

function Slice:drawnut()
   self.p1x = self._p1x
   self.p1y = self._p1y
   self.lw = 7
   self.timer:tween(.4, self, {lw = -0.1}, 'out-cubic')
end

Dust = Class:extend()
Dust:implement(GameObject)

function Dust:new(args)
   self:init_game_obj(args)
   self.color = self.color or assets.color_effects
   if not self.special then self.timer:tween(0.5,  self, {radius = -0.2}, 'out-cubic') end
   if self.special then self.lw = 20 self.timer:tween(0.5,  self, {radius = self.radius * 2, lw = 0}, 'out-cubic') end
end

function Dust:update(dt)
   self:update_game_obj(dt)
   self.x = self.x + self.x_vel * dt
   self.y = self.y + self.y_vel * dt
   if self.follow then
      self.x, self.y = self.follow.x, self.follow.y + self.ydiff
   end
   if self.radius < 0 then self.remove = true end
end

function Dust:draw()
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   graphics.circle(self.x, self.y, self.radius, self.color, self.lw)
   graphics.pop()
end


Doppelganger = Class:extend()
Doppelganger:implement(GameObject)

function Doppelganger:new(args)
   self:init_game_obj(args)
   self.class = 'Doppelganger'
   self.color = Color(.6, .6, .6, .2)
   self.color2 = Color("#03ffb3")
   self.cam = main.current.cam

   self.w, self.h = 32, 32
   self.x_vel, self.y_vel = self.x_vel, 0
   self.angle = 0
   self.ox, self.oy = 16, 14
   self.sx = 1
   self.sy = self.sy or 1

   self.runsheet = love.graphics.newImage('assets/images/playersheet.png')
   local g = anim8.newGrid(32, 32, self.runsheet:getWidth(), self.runsheet:getHeight())
   self.run = anim8.newAnimation(g('1-4', 1), 0.05)
   self.runleft = self.run:clone():flipH()


   self.flipx = self.flipx or false
   self.grounded = false
   self.charge_jump = 0
   self.is_jumping = false
   self.can_move =  true
   self.can_die = true
   self.draw_attack = true
   self.move_speed = 150
   self.default_move_speed = 150
   self.buff = 'NOBUFF'
   self.pbuff = 'NOBUFF'
   self.buffs = {
      '2XSCORE',
      'SLOW',
      'FAST',
   }


   self.timer_special = Timer()


   self.curr_side = self.curr_side or 'down'
   self.timer:every(.15, function()
      local ydir = self.y > game_height/2 and -1 or 1
      for i = 1, 4 do Dust{group = main.current.main, x = self.x, y = self.y - 2 * ydir, x_vel = sign(self.x_vel) * randomdir(-30, -20), y_vel = ydir * randomdir(15, 25), radius = randomdir(3, 5)} end
   end)

end

function Doppelganger:update(dt)
   self:update_game_obj(dt)
   self.timer_special:update(global_dt)
   if self.player.dead then
      self:die()
   end

   if not self.can_move then return end
   self:move(dt)
end

function Doppelganger:die()
   self.remove = true
   self.player.doppelganger_clone = nil
   local ydir = self.y > game_height/2 and -1 or 1
   Dust{group = main.current.main, x = self.x, y = self.y + 4 * ydir, x_vel = 0, y_vel = 0, radius = 15, special = true, color = assets.color_jumperbonus}

end

function Doppelganger:move(dt)
   -- self.angle = self.angle + dt * 3
   self.run:update(dt)
   self.runleft:update(dt)

   if self.player.buff == 'SLOW' then
      self.move_speed = 120
   elseif self.player.buff == 'FAST' then
      self.move_speed = 180
   else
      self.move_speed = self.default_move_speed
   end

   self.x = self.x + self.x_vel * self.move_speed * dt

   if self.x_vel < 0 and self.x < 16 then
      self.x = 20
      self.x_vel = self.x_vel * -1
      self.flipx = not self.flipx
   end
   if self.x_vel > 0 and self.x > game_width - 24 then
      self.x_vel = self.x_vel * -1
      self.x = game_width - 20
      self.flipx = not self.flipx
   end
   -- main.current.angleoffset = lerp(-0.02, 0.02, self.x/game_width)

end

function Doppelganger:attack()
   -- sfx.slice:play()
   self.flipx = not self.flipx
   self.x_vel = self.x_vel * -1
   local prevx, prevy = self.x, self.y
   if self.curr_side == 'down' then
      self.y = 0 + 16
      self.sy = -1
      self.curr_side = 'up'
   elseif self.curr_side == 'up' then
      self.y = game_height - 16
      self.sy = 1
      self.curr_side = 'down'
   end
   Slice{group = main.current.main, p1x = prevx, p1y = prevy, p2x = self.x, p2y = self.y}
   -- local hits = main.current.main:query_line(self.x, 20)
   -- local combo = #hits > 1 and true or false
   -- for _, e in ipairs(hits) do
   --    e:die(true, combo)
   --    HitCircle{group = main.current.main, x = e.x, y = e.y, radius = 10 + (#hits - 1) * 5}
   --    self.cam:shake(6 + #hits -1, .2, 40, 'Y')
   --    for i = 1, 10 * #hits/2 do
   --       Sparks{group = main.current.main, x = e.x, y = e.y}
   --    end
   -- end
   local ydir = self.y > game_height/2 and -1 or 1
   for i = 1, 12 do Dust{group = main.current.main, x = self.x, y = self.y - 2 * ydir, x_vel = love.math.random(-150, 150), y_vel = ydir * randomdir(20, 35), radius = randomdir(4, 6)} end
   return hits
end

function Doppelganger:draw()
   if self.hidden then return end
   graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
   if self.draw_attack then graphics.polyline(self.color, self.lw, self.x + .5, self.y - 16, self.x, self.y - game_height) end
   love.graphics.setColor(self.color2.r, self.color2.b, self.color2.g, self.color2.a)
   if not self.flipx then
      self.run:draw(self.runsheet, self.x - self.w/2, self.y - self.h/2 + 8 - self.oy)
   else
      self.runleft:draw(self.runsheet, self.x - self.w/2, self.y - self.h/2 + 8 - self.oy)
   end
   love.graphics.setColor(1, 1, 1)
   graphics.pop()
end
