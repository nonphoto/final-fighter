require("direction")
inspect = require("inspect")
--require("effect")

Player = {}
Player.new = function (character, x, y)
   local result = clone(Player)
   result.x = x or 0
   result.y = y or 0
   result.r = 10
   result.character = character
   result.direction = Direction.fromString("south")
   result.moving = false
   result.currentAction = nil
   result.nextAction = nil
   result.startFrame = nil
   result.knockback = {}
   result.nextQuad = nil
   return result
end

function Player:handleInput(modifier, direction)
   local action
   self.moving = false
   if modifier then
      action = self:translateInput(modifier, direction)
   elseif not self.currentAction then
      for key, value in pairs(self.keybindings) do
         if love.keyboard.isDown(key)
         and self.keybindings[key] ~= "primary"
         and self.keybindings[key] ~= "secondary" then
            local direction = Direction.subtract(Direction.fromString(value), self.direction)
            action = self.character.move[Direction.toString(direction)]
            self.moving = true
         end
      end
   end
   self:queueAction(action)
end

function Player:queueAction(action)
   if not self.currentAction then -- nil _
      self.currentAction = action
      self.startFrame = frame
   elseif not self.nextAction then -- _ nil
      self.nextAction = action
   end
end

function Player:translateInput(modifier, directionName)
   if directionName then
      local direction = Direction.subtract(Direction.fromString(directionName), self.direction)
      return self.character[modifier][Direction.toString(direction)]
   else
      return self.character[modifier]["neutral"]
   end
end

function Player:endAction()
   if self.nextAction then
      self.currentAction = self.nextAction
      self.startFrame = frame

      self.nextAction = nil
   else
      self.currentAction = nil
      self.startFrame = nil
   end
end

function Player:update(frame)
   if self.currentAction then
      if self.moving then
         self.currentAction(self, frame)
      else
         self.currentAction(self, frame - self.startFrame)
      end
   else
      self.character.idle(self, frame - self.startFrame)
   end
end

function Player:draw(frame)
   if self.nextQuad then
      love.graphics.setColor(0, 0, 0)
      love.graphics.draw(self.character.image, self.nextQuad, self.x - 7, self.y - 22, nil, 1, 0.5, nil, nil, -0.5, nil)
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(self.character.image, self.nextQuad, self.x - 32, self.y - 48)
      self.nextQuad = nil
   end
end


-- The following functions take directions in player space
-- FORWARD, BACKWARD, LEFT, RIGHT, are all relative to
-- the current facing direction

function Player:move(direction, pixels)
   local absoluteDirection = Direction.add(self.direction, direction)

   local newX = self.x + Direction.dx(absoluteDirection) * pixels
   local newY = self.y + Direction.dy(absoluteDirection) * pixels

   if (background:inBounds(newX, newY)) then
      self.x = newX
      self.y = newY
   end
end

function Player:face(direction)
   self.direction = Direction.add(self.direction, direction)
end

function Player:attack(r, angle, power)
   local other = self
   if self == player1 then
      other = player2
   elseif self == player2 then
      other = player1
   end
   
   local hit, blocked = other:testHit(self, r, angle)
   if hit then
      other:clearActions()
      other.currentAction = self.character.knockback

      other.knockback.direction = self.direction
      other.knockback.duration = power
      other.startFrame = frame
   end
end

function Player:testHit(other, r, angle)
   local dx = self.x - other.x
   local dy = self.y - other.y
   local d2 = dx * dx + dy * dy
   local r2 = (r + self.r) * (r + self.r)
   local blocked = self.isBlocking
   local hit = false
   local withinAngle = math.atan(dy/dx) * 180/math.pi < (angle/2)
      or math.atan(dx/dy) * 180/math.pi < (angle/2)
   local facing = dx * Direction.dx(other.direction) > 0
      or dy * Direction.dy(other.direction) > 0
   if d2 < r2 and withinAngle and facing then
      hit = true
   end
   return hit, blocked
end

function Player:clearActions()
   self.currentAction = nil
   self.nextAction = nil
end

function Player:toPlayerDirection(direction)
   return Direction.subtract(direction, self.direction)
end
