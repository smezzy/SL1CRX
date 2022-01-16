Physics = Class:extend()


function Physics:init_physics(w, h, centered)
   if not self.x or not self.y or not self.w or not self.h then
      error('GameObject ~' ..self.class ..'~ has invalid transform properties')
      return
   end
   self.mouse_stay = false
   main.current.world:add(self, self.x, self.y, w or self.w, h or self.h)
end

function Physics:move_and_slide(dirx, diry, dt, filter)
   local actual_x, actual_y, cols, len = main.current.world:move(self, self.x + dirx * dt, self.y + diry * dt, filter)
   self.x, self.y = actual_x, actual_y
   if len > 0 then
      if self.on_collision_enter then self:on_collision_enter(cols) end
   end
   if self.check_collisions then self:check_collisions(cols) end
end

function Physics:apply_gravity(dt)
   self.y_vel = self.y_vel + 500 * dt
end

function Physics:is_colliding_with_point(px, py)
   if px > self.x - self.w/2 and px < self.x + self.w - self.w/2 and py > self.y - self.h/2 and py < self.y + self.h - self.h/2 then return true end
   return false
end

function Physics:update_physics(dt)
   if self.interact_with_mouse then
      local mx, my = get_global_mouse_pos()
      if self:is_colliding_with_point(mx, my) then
         if not self.mouse_stay then
            if self.on_mouse_enter then self:on_mouse_enter() end
            self.mouse_stay = true
         end
         if self.on_mouse_stay then self:on_mouse_stay() end
      else
         if self.mouse_stay then
            self.mouse_stay = false
            if self.on_mouse_exit then self:on_mouse_exit() end
         end
      end
   end
end
