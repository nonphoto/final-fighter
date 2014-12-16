
camera = {}
camera.x = 100
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

function camera:set()
   love.graphics.push()
   love.graphics.rotate(-self.rotation)
   love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
   love.graphics.translate(-self.x + love.graphics.getWidth() / 2 * self.scaleX,
			      -self.y + love.graphics.getHeight() / 2 * self.scaleY)
end

function camera:unset()
   love.graphics.pop()
   
   love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 1, love.graphics.getHeight() / 2 - 1, 3, 3)
end

function camera:move(dx, dy)
   self.x = self.x + (dx or 0)
   self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
   self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
   sx = sx or 1
   self.scaleX = self.scaleX * sx
   self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
   self.x = math.floor(x) or self.x
   self.y = math.floor(y) or self.y
end

function camera:setScale(sx, sy)
   self.scaleX = sx or self.scaleX
   self.scaleY = sy or self.scaleY
end
