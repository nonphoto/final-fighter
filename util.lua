inspect = require("inspect")

function clone( base_object, clone_object )
   if type( base_object ) ~= "table" then
      return clone_object or base_object 
   end
   clone_object = clone_object or {}
   clone_object.__index = base_object
   return setmetatable(clone_object, clone_object)
end

function colorEquals(color, r, g, b)
   return color.r == r and color.g == g and color.b == b
end

-- How cool is this?
-- Push a function onto the table to do something when the next draw call comes around

drawQueue= {}

function drawQueue:run()
   while self[1] do
      local effect = table.remove(self)
      effect()
   end
end

function drawQueue:push(effect)
   table.insert(self, effect)
end
