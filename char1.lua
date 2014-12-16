require("direction")

character1 = {}

character1.quads = {
   forward = {},
   backward = {},
   left = {},
   right = {},
   
}

local tileSize = 64
local image = love.graphics.newImage("assets/character1.png")
image:setFilter("nearest", "nearest")
local w = image:getWidth() / tileSize
local h = image:getHeight() / tileSize

for direction, quads in pairs(character1.quads) do
   for i = 0, w - 1 do
      local j = Direction.fromString(direction)
      quads[i + 1] = love.graphics.newQuad(
	 i * tileSize,
	 j * tileSize,
	 tileSize,
	 tileSize,
	 image:getWidth(),
	 image:getHeight())
   end
end

character1.image = image

character1.idle = function(player, frame)
   local quad = character1.quads[Direction.toString(player.direction)][1]
   player.nextQuad = quad
end

character1.move = {
   forward = function(player, frame)
      player:move(Direction.FORWARD, 2)
      player:endAction()
      local quad = character1.quads[Direction.toString(player.direction)][math.floor(frame / 8) % 4 + 4]
      player.nextQuad = quad
   end,
   backward = function(player, frame)
      player:face(Direction.BACKWARD)
      player:move(Direction.FORWARD, 2)
      player:endAction()
      local quad = character1.quads[Direction.toString(player.direction)][math.floor(frame / 8) % 4 + 4]
      player.nextQuad = quad
   end,
   left = function(player, frame)
      player:face(Direction.LEFT)
      player:move(Direction.FORWARD, 2)
      player:endAction()
      local quad = character1.quads[Direction.toString(player.direction)][math.floor(frame / 8) % 4 + 4]
      player.nextQuad = quad
   end,
   right = function(player, frame)
      player:face(Direction.LEFT)
      player:move(Direction.FORWARD, 2)
      player:endAction()
      local quad = character1.quads[Direction.toString(player.direction)][math.floor(frame / 8) % 4 + 4]
      player.nextQuad = quad
   end
}

character1.primary = {
   forward = function(player, frame)
      if frame > 32 then
	 player:endAction()
      elseif frame == 1 then
         player:face(Direction.FORWARD)
      elseif frame == 16 then
         player:move(Direction.FORWARD, 14)
         player:attack(100, 90, 32)
      end
      if frame < 16 then
         player.nextQuad = character1.quads[Direction.toString(player.direction)][2]
      else
         player.nextQuad = character1.quads[Direction.toString(player.direction)][3]
      end
   end,
   backward = function(player, frame)
      if frame > 32 then
	 player:endAction()
      elseif frame == 1 then
	 player:face(Direction.BACKWARD)
      elseif frame == 16 then
	 player:move(Direction.FORWARD, 14)
	 player:attack(32, 90, 32)
      end
      if frame < 16 then
	 player.nextQuad = character1.quads[Direction.toString(player.direction)][2]
      else
	 player.nextQuad = character1.quads[Direction.toString(player.direction)][3]
      end
   end,
   left = function(player, frame)
      if frame > 32 then
	 player:endAction()
      elseif frame == 1 then
         player:face(Direction.LEFT)
      elseif frame == 16 then
         player:move(Direction.FORWARD, 14)
         player:attack(32, 90, 32)
      end
      if frame < 16 then
         player.nextQuad = character1.quads[Direction.toString(player.direction)][2]
      else
         player.nextQuad = character1.quads[Direction.toString(player.direction)][3]
      end
   end,
   right = function(player, frame)
      if frame > 32 then
	 player:endAction()
      elseif frame == 1 then
         player:face(Direction.RIGHT)
      elseif frame == 16 then
         player:move(Direction.FORWARD, 14)
         player:attack(32, 90, 32)
      end
      if frame < 16 then
         player.nextQuad = character1.quads[Direction.toString(player.direction)][2]
      else
         player.nextQuad = character1.quads[Direction.toString(player.direction)][3]
      end
   end,
   neutral = function(player, frame)
      if frame > 8 then
	 player:endAction()
      else
	 if frame == 1 then
	    player:face(Direction.FORWARD)
         elseif frame == 4 then
	    player:move(Direction.FORWARD, 12)
            player:attack(32, 90, 8)
	 end
      end
      player.nextQuad = character1.quads[Direction.toString(player.direction)][math.floor(frame/4) + 2]
   end
}

character1.secondary = {
   forward = function(player, frame)
      if frame > 8 then
	 player:endAction()
      elseif frame == 1 then
         player:face(Direction.FORWARD)
      else
         player:move(Direction.FORWARD, 5)
      end
      player.nextQuad = character1.quads[Direction.toString(player.direction)][1]
   end,
   
   right = function(player, frame)
      if frame > 8 then
	 player:endAction()
      else
	 if frame == 1 then
	    player:face(Direction.RIGHT)
         else
	    player:move(Direction.FORWARD, 5)
	 end
      end
      player.nextQuad = character1.quads[Direction.toString(player.direction)][1]
   end,

   backward = function(player, frame)
      if frame > 8 then
	 player:endAction()
      else
	 if frame == 1 then
	    player:face(Direction.BACKWARD)
         else
	    player:move(Direction.FORWARD, 5)
	 end
      end
      player.nextQuad = character1.quads[Direction.toString(player.direction)][1]
   end,
   
   left = function(player, frame)
      if frame > 8 then
	 player:endAction()
      else
	 if frame == 1 then
	    player:face(Direction.LEFT)
         else
	    player:move(Direction.FORWARD, 5)
	 end
      end
      player.nextQuad = character1.quads[Direction.toString(player.direction)][1]
   end,

   neutral = function(player, frame)
      if frame > 8 then
	 player:endAction()
      else
	 if frame == 1 then
	    player:face(Direction.FORWARD)
         else
	    player:move(Direction.FORWARD, 5)
	 end
      end
      player.nextQuad = character1.quads[Direction.toString(player.direction)][1]
   end
}

character1.knockback = function(player, frame)
   if frame > player.knockback.duration then
      player:endAction()
   else
      local direction = player:toPlayerDirection(player.knockback.direction)
      player:move(direction, 2)
   end
   player.nextQuad = character1.quads[Direction.toString(player.direction)][8]
end
