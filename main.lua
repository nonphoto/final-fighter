require("input")
require("keybindings")
require("util")
require("map")
require("player")
require("camera")
require("char1")
require("char2")

TILE_SIZE = 32
FRAME_GAP = 3

frame = 0
lastInputFrame1 = 0
lastInputFrame2 = 0

function love.load()
   print("Loading")
   love.graphics.setBackgroundColor(56, 46, 41)
   camera:setScale(0.5, 0.5)
   
   background = Map.new("assets/background1.png", "assets/tileset.png", "assets/key1.png", TILE_SIZE)
   foreground = Map.new("assets/foreground1.png", "assets/wallset.png", nil, TILE_SIZE)

   player1 = Player.new(character1,
			background.terrain.spawn1.x * TILE_SIZE + (TILE_SIZE / 2),
			background.terrain.spawn1.y * TILE_SIZE + (TILE_SIZE / 2))
   player1.keybindings = keybindings.player1

   player2 = Player.new(character2,
			background.terrain.spawn2.x * TILE_SIZE + (TILE_SIZE / 2),
			background.terrain.spawn2.y * TILE_SIZE + (TILE_SIZE / 2))
   player2.keybindings = keybindings.player2
   
   inputs1 = {}
   inputs2 = {}
end

function love.draw()
   camera:set()
   background:draw(0, 0)
   player1:draw(frame)
   player2:draw(frame)
   foreground:draw(0, -20)
   drawQueue:run()
   camera:unset()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
   if key == "t" then
      player1:move(Direction.BACKWARD, 1)
   end

   local key1 = keybindings.player1[key]
   if key1 then
      table.insert(inputs1, {value = key1, frame = frame})
      lastInputFrame1 = frame
   end
   
   local key2 = keybindings.player2[key]
   if key2 then
      table.insert(inputs2, {value = key2, frame = frame})
      lastInputFrame2 = frame
   end
end

function love.update(dt)
   do
      local modifier, direction = processInputs(inputs1, lastInputFrame1)
      player1:handleInput(modifier, direction)
   end

   do
      local modifier, direction = processInputs(inputs2, lastInputFrame2)
      player2:handleInput(modifier, direction)
   end
	     
   player1:update(frame)
   player2:update(frame)
	     
   camera:setPosition((player1.x + player2.x) / 2, (player1.y + player2.y) / 2)
	     
   frame = frame + 1
end

function processInputs(inputs, lastInputFrame)
   if frame - lastInputFrame > FRAME_GAP then
      local key1 = inputs[1]
      local key2 = inputs[2]
      if key1 then
	 local modifier1 = key1.value == "primary" or key1.value == "secondary"
	 if key2 then
	    local modifier2 = key2.value == "primary" or key2.value == "secondary"
	    if modifier1 ~= modifier2
	    and math.abs(key1.frame - key2.frame) < FRAME_GAP then
	       table.remove(inputs, 2)
	       table.remove(inputs, 1)
	       if modifier1 then return key1.value, key2.value
	       else return key2.value, key1.value
	       end
	    end
	 end
	 table.remove(inputs, 1)
	 if modifier1 then return key1.value, nil
	 else return nil, key1.value
	 end
      end
   end
end
