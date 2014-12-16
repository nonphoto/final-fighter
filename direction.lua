Direction = {
   north = 0,
   east = 1,
   south = 2,
   west = 3,
   up = 0,
   right = 1,
   down = 2,
   left = 3,
   forward = 0,
   backward = 2,
   none = nil,

   NORTH = 0,
   EAST = 1,
   SOUTH = 2,
   WEST = 3,
   UP = 0,
   RIGHT = 1,
   DOWN = 2,
   LEFT = 3,
   FORWARD = 0,
   BACKWARD = 2,
   NONE = nil
}

function Direction.add(a, b)
   if a == Direction.none or b == Direction.none then
      return Direction.none
   else
      return (a + b) % 4
   end
end

function Direction.subtract(a, b)
   if a == Direction.none or b == Direction.none then
      return Direction.none
   else
      return (a - b) % 4
   end
end

function Direction.dx(dir)
   if dir == Direction.none then return 0
   elseif dir == Direction.north then return 0
   elseif dir == Direction.east then return 1
   elseif dir == Direction.south then return 0
   elseif dir == Direction.west then return -1
   end
end

function Direction.dy(dir)
   if dir == Direction.none then return 0
   elseif dir == Direction.north then return -1
   elseif dir == Direction.east then return 0
   elseif dir == Direction.south then return 1
   elseif dir == Direction.west then return 0
   end
end

function Direction.fromString(s)
   return Direction[s]
end

function Direction.toString(dir)
   if dir == 0 then return "forward"
   elseif dir == 1 then return "right"
   elseif dir == 2 then return "backward"
   elseif dir == 3 then return "left"
   else return "neutral"
   end
end
