Sparks = Class:extend()
Sparks:implement(GameObject)

function Sparks:new(args)

   self:init_game_obj(args)
   self.speed = self.speed or love.math.random(3, 6)
   self.r = randomdir(-math.pi, math.pi)
   self.scale = self.scale or 2
   self.velocity = self.velocity or 60
   self.points = {}
   self.color = self.color or assets.color_effects
end

function Sparks:update(dt)
   movex, movey = self:calculate_movement(dt)
   self.x = self.x + movex * self.velocity
   self.y = self.y + movey * self.velocity
   -- self.r = self.r + 3 * dt
   self.speed = self.speed - 5 * dt
   self.points = {
      self.x + math.cos(self.r) * self.speed * self.scale, self.y + math.sin(self.r) * self.speed * self.scale,
      self.x + math.cos(self.r + math.pi / 2) * self.speed * self.scale * 0.3, self.y + math.sin(self.r + math.pi / 2) * self.speed * self.scale * 0.3,
      self.x - math.cos(self.r) * self.speed * self.scale * 3.5, self.y - math.sin(self.r) * self.speed * self.scale * 3.5,
      self.x + math.cos(self.r - math.pi / 2) * self.speed * self.scale * 0.3, self.y - math.sin(self.r + math.pi / 2) * self.speed * self.scale * 0.3,
   }
   if self.speed < 0 then self.remove = true end
end

function Sparks:calculate_movement(dt)
   return math.cos(self.r) * self.speed * dt, math.sin(self.r) * self.speed * dt
end

function Sparks:draw()
   if self.remove then return end
   love.graphics.push()
   love.graphics.setColor(self.color.r, self.color.g, self.color.b)
   love.graphics.polygon("fill", self.points)
   -- love.graphics.setBlendMode('add')
   -- love.graphics.setColor(self.color.r, self.color.g, self.color.b, .2)
   -- love.graphics.translate(self.x, self.y)
   -- love.graphics.scale(1.5, 1.5)
   -- love.graphics.translate(-self.x, -self.y)
   -- love.graphics.polygon("fill", self.points)
   -- love.graphics.translate(self.x, self.y)
   -- love.graphics.scale(1.3, 1.3)
   -- love.graphics.translate(-self.x, -self.y)
   -- love.graphics.polygon("fill", self.points)
   -- love.graphics.setBlendMode('alpha')
   -- love.graphics.translate(self.x, self.y)

   love.graphics.setColor(1, 1, 1)
   love.graphics.pop()
end



HitCircle = Class:extend()
HitCircle:implement(GameObject)

function HitCircle:new(args)
   self:init_game_obj(args)
   self.radius = self.radius or 10
   self.lw = self.radius or 10
   self.max = self.radius * 3
   self.color = assets.color_effects
end

function HitCircle:update(dt)
   self:update_game_obj(dt)
   if self.radius > self.max then self.remove = true return end
   self.lw = self.lw - dt * 80
   if self.lw < 0 then
      self.lw = 0
   end
   self.radius = self.radius + 80 * dt
end

function HitCircle:draw()
   love.graphics.setColor(self.color.r, self.color.g, self.color.b)
   love.graphics.setLineWidth(self.lw)
   love.graphics.circle("line", self.x, self.y, self.radius)
   love.graphics.setLineWidth(1)
   love.graphics.setColor(1, 1, 1)
end
