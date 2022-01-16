Score = Class:extend()

function Score:new()
   self.points = 0
   self.font = assets.main_font
   self.timer = Timer()
   self.spring = Spring()
   self.x, self.y = 0, 0
   self.angle = 0
   self.sx, self.sy = 1, 1
   self.spawn_shield = false
end

function Score:update(dt)
   self.timer:update(dt)
   self.spring:update(dt)
end

function Score:addscore(x)
   self.points = self.points + x
   self.spring:pull(5)
   if self.points > 50 then main.current:activate_wave('C') end
   if self.points > 100 and not self.spawn_shield then
      self.spawn_shield = true
      Jumper{group = main.current.main, y_vel = love.math.random(-230, -280), x_vel = love.math.random(50, -50), x = love.math.random(0, game_width), y = game_height, size = 10, gravity = 7, invincible = true}
   end
   if self.points > 150 then main.current:activate_wave('A') end
   if self.points > 250 then main.current:activate_wave('B') end
end

function Score:draw()
   local color = assets.color_bg
   local color2 = assets.color_effects
   love.graphics.setColor(color.r, color.g, color.b)
   love.graphics.rectangle("fill", 0, 0, game_width, 16)
   love.graphics.setColor(color2.r, color2.g, color2.b)
   love.graphics.line(0, 15, game_width, 15)
   local txt = 'SCORE: ' ..self.points
   local tw,th = self.font:getWidth(txt), self.font:getHeight(txt)
   graphics.push(game_width/2, self.y - th, self.angle, self.sx + self.spring.x, self.sy + self.spring.x)
   graphics.print_centered(main.current.player.power, game_width/2 - tw/2 - 8, 7, assets.secondary_font, assets.color_jumperbonus, 'right')
   graphics.print_centered(main.current.player.buff, game_width/2 + tw/2 + 8, 7, assets.secondary_font, assets.color_jumperscore,'left')
   graphics.print_centered(txt, game_width/2, 7, self.font, assets.color_effects)
   graphics.pop()
end


ScoreText = Class:extend()
ScoreText:implement(GameObject)

function ScoreText:new(args)
   self:init_game_obj(args)
   self.color = assets.color_effects
   self.color1 = assets.color_effects
   self.color2 = self.color2
   self.switch = false
   self.switchg = self.switchg or false
   self.duration = self.duration or 0.7
   self.timer:after(self.duration, function() self.remove = true end)
   self.timer:every(0.05,  function() self.switch = not self.switch end)
   if self.x - assets.main_font:getWidth(self.text)/2 < 16 then self.x = 16 + assets.main_font:getWidth(self.text)/2 end
   if self.x + assets.main_font:getWidth(self.text)/2 > game_width - 16 then self.x = game_width - 16 - assets.main_font:getWidth(self.text)/2 end
   self.spring:pull(40, 250, 16)
end

function ScoreText:update(dt)
   self:update_game_obj(dt)
   if self.switchg then self.y = self.y + 20 * dt else self.y = self.y - 20 * dt  end
   if self.switch then
      self.color = self.color1
   else
      self.color = self.color2
   end
end

function ScoreText:draw()
   -- love.graphics.translate(self.x, self.y)
   graphics.push(self.x, self.y, self.angle, self.sx + self.spring.x,  self.sy + self.spring.x)
   graphics.print_centered(self.text, self.x, self.y, assets.main_font, self.color)
   -- love.graphics.translate(-self.x, -self.y)
   graphics.pop()
end


ComboText = Class:extend()
ComboText:implement(GameObject)

function ComboText:new(args)
   self:init_game_obj(args)
   self.color = assets.color_effects
   self.color1 = assets.color_effects
   self.color2 = self.color2
   self.x, self.y = game_width/2, self.yy or game_height/2
   self.force = self.force or 1
   self.spring:pull(5 * self.force, 70, 10)
   self.switch = true
   self.duration = self.duration or 1.5
   self.t = self.t or 0
   if self.special then return end


   self.timer:after(self.duration, function() self.remove = true end)
   self.timer:every(0.05,  function() self.switch = not self.switch end)
end

function ComboText:update(dt)
   if self.special then self:update_game_obj(global_dt) else self:update_game_obj(dt) end
   if not self.special then self.y = self.y - 10 * dt  else self.y = self.y - 20 * dt end
   self.t = self.t + dt * 10 * self.force
   if not self.switch then
      self.color = self.color1
   else
      self.color = self.color2
   end

   self.angle = math.sin(self.t) * .05

end

function ComboText:draw()
   graphics.push(self.x, self.y, self.angle, self.sx + self.spring.x, self.sy + self.spring.x)
   -- love.graphics.translate(self.x, self.y)
   graphics.print_centered(self.text, self.x + 1, self.y + 1, assets.main_font, assets.color_bg)
   graphics.print_centered(self.text, self.x, self.y, assets.main_font, self.color)
   -- love.graphics.translate(-self.x, -self.y)
   graphics.pop()
end




SimpleText = Class:extend()
SimpleText:implement(GameObject)

function SimpleText:new(args)
   self:init_game_obj(args)
   self.color = self.color or assets.color_effects
   self.duration = self.duration or 0.5
   self.timer:after(self.duration, function() self.remove = true end)
end

function SimpleText:update(dt)
   self:update_game_obj(dt)

end

function SimpleText:draw()
   -- love.graphics.translate(self.x, self.y)
   graphics.print_centered(self.text, self.x, self.y + 1, assets.main_font, assets.color_bg)
   graphics.print_centered(self.text, self.x, self.y, assets.main_font, self.color)
   -- love.graphics.translate(-self.x, -self.y)
end
