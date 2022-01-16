--[[

PlayState = Class:extend()
PlayState:implement(State)

function PlayState:new(name)
   self:init_state(name)
   self.timer = Timer()
   self.main = Group()
   self.persistent_draw = false
   self.persistent_update = false
end


function PlayState:on_enter(from

end

function PlayState:update(dt)
   self.main:update(dt)
   camera:update(dt)
   if self.timer then self.timer:update(dt) end

end

function PlayState:draw()
   camera:attach()
   self.map:drawLayer(self.map.layers["Camada de Tiles 1"])
   self.main:draw()
   camera:detach()

end

]]

--[[

Object = Class:extend()
Object:implement(Physics)

function Object:new(group, x, y)
   -- game object
   self.class = 'Object'
   self.id = utils.UUID()
   self.x = x or 0
   self.y = y or 0
   self.group = group
   self.group:add(self)

   self.scene = main.current.main

   return self
end

function Object:update(dt)

end


function Object:draw()

end

]]
