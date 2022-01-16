GameObject = Class:extend()

function GameObject:init_game_obj(args)
   for k, v in pairs(args) do self[k] = v end
   -- game object
   self.class = 'GameObject'
   self.id = self.id or uid()
   if self.group then self.group:add(self) else error('you forget group men  something wonrng') end

   --transform
   self.x, self.y = self.x or 0, self.y or 0
   self.angle = self.angle or 0
   self.ox, self.oy = self.ox or 0, self.oy or 0
   self.sx, self.sy = self.sx or 1, self.sy or 1
   self.z = self.z or 1
   --stuff
   self.timer = Timer()
   self.spring = Spring()

   return self
end

function GameObject:update_game_obj(dt)
   self.timer:update(dt)
   self.spring:update(dt)

end
