Group = Class:extend()

function Group:new()
   self.objects = {}
   -- self.objects.by_class = {}
end

function Group:update(dt)
   -- table.sort(self.objects, function(a, b) return a.z < b.z end)
   for _, object  in ipairs(self.objects)  do
      object:update(dt)
   end

   for i = #self.objects, 1, -1 do
      local object = self.objects[i]
      if object.remove then
         if object.hasphysics then main.current.world:remove(object)  end
         table.remove(self.objects, i)
      end
   end
end

function Group:draw()
   for _, object in ipairs(self.objects) do
      object:draw()
   end
end

-- Add GameObject to the area, called like this Group:instantiate('ClassName', x, y, table_with_additional_properties)
function Group:add(object)
   object.group = self
   if not object.class then error("object doesn't have a class") end
   -- if not self.objects.by_class[object.class] then self.objects.by_class[object.class] = {} end
   -- table.insert(self.objects.by_class[object.class], object)
   table.insert(self.objects, object)
end

function Group:get_objects(f)
   return fn.select(self.objects, f)
end

function Group:get_objects_by_class(class)
   return self.objects.by_class[class] or {}
end


-- function Group:query_circle_area(x, y, radius, object_types)
--    -- object_types must be table please if bug prob because objects pleas only table laik this { Rectangle, Circle2}
--    local out = {}
--
--    for _, entity in ipairs(self.entities) do
--       if fn.any(object_types, entity.class) then
--          if utils.sqr_distance(entity.x, entity.y, x, y) < radius*radius then
--             table.insert(out, entity)
--          end
--       end
--    end
--
--    return out
-- end
--
-- function Group:get_closest_object(x, y, radius, object_types)
--    local circle_area = self:query_circle_area(x, y, radius, object_types)
--    table.sort(circle_area, function(a, b)
--       local da = utils.sqr_distance(x, y, a.x, a.y)
--       local db = utils.sqr_distance(x, y, a.x, a.y)
--       return da < db
--    end)
--
--    return circle_area[1]
-- end



function Group:query_line(x, w)

   local hits = {}
   for _, obj in ipairs(self.objects) do
      if obj:is(Jumper) or obj:is(Bumper) then
         if obj.x > x - w and obj.x < x + w then table.insert(hits, obj) end
      end
   end
   return hits
end
