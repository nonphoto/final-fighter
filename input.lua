require("util")
require("direction")

Input = {}

Input.new = function()
   local result = clone(Input)
   return result
end

Input.direction = function(self)
   if self.up then return Direction.NORTH
   elseif self.down then return Direction.SOUTH
   elseif self.left then return Direction.WEST
   elseif self.right then return Direction.EAST
   else return Direction.NONE
   end
end

Input.xy = function(self)
   local x = 0
   local y = 0
   if self.up then y = y - 1 end
   if self.down then y = y + 1 end 
   if self.left then x = x - 1 end
   if self.right then x = x + 1 end
   return x, y
end
