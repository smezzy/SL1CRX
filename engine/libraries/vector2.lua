local Vector2 = {}

function Vector2:lenght(x, y)
   return math.sqrt(x*x + y*y)
end

function Vector2:normalize(x, y)
   local len = self:lenght(x, y)
   if len > 0 then
      return x/len, y/len
   end
   return x, y
end

return Vector2
