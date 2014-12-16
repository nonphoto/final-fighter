# DEVELOPMENT JOURNAL

Williams CSCI 371 Final Project
Jonas Luebbers (jkl1) and Benji Jones (bsj1)
Fall 2014

## Week 3

### Sunday

Got some great work done today. First, we got the walls working (although they may be broken because of current work).  Then we incorporated our previous code for collisions, fixing a few bugs along the way.  Also implemented and bug-fixed was ability queueing, although it still remains to resolve directions properly- shouldn't be a hard fix.  We also finally got around to the long-awaited standardization of input-movement control flow.  Now, all movement is event-based, but we still have the responsiveness of the held button for movement.

We've also been working on tile/art, progress is slow, but we're still iterating and moving forward.

## Week 2

### Thanksgiving Break

I won't put much here because I didn't do all that much. I fixed event based inputs by removing the Input class, and turning the Direction class into a table with some utility functions in it. Directions are now just integers, but you can translate them into strings and back. The upside is that checking for simultaneous inputs is nice and flexible, with no bugs that I can see so far.

### Monday

I improved our implementation of basic walking today.  In player.lua it's important to note that there are two handleInput methods, where before there was just a single processInput method.  What this allows us to do is take care of non-modified input (which doesn't need any queue) for basic walking.  The hope is that this will make basic walking smoother and easier to implement while still preserving the part of the code that handles input combos.  The handleInputDefault method uses love.keyboard.isDown just to see what buttons are being pressed on any frame when we don't consume the queue.  The handleInputCombos method is only called once every few frames, and still works as described below.

However, I still can't figure out why holding down the button doesn't seem to move the player, since the nextAction field is definitely being set.  Will have to look into it further.

I figured out how to fix event based walking. Input objects now store whether the key was pressed or released. Input:direction() already returned Direction.NONE when the inputs are false, so it worked fine as long as the character.move functions were defined properly.

However, I see two problems with this approach. The player doesn't stop moving if two directions are pressed, and this method probably won't work for gamepads. I will try to implement a system that doesn't use input events as an alternative.

For tomorrow, we still need collision detection with walls, and player knockback. Walls should be easy enough because we know where the walls are so we can just add a check in Player:move(), but knockback should be tougher. Maybe we should put the player in a "disabled" state when they get hit that overrides all inputs and moves the player automatically?

### Sunday

We need to adjust our input processing code so that it's more lenient in allowing combinations of inputs, i.e. ATTACK + RIGHT.  Currently the engine only accepts such inputs if both buttons are pressed within the same frame.

We solved this by putting key events in a queue from which they can be processed later. When a key is pressed, the following things happen immediately:
1. Store the key if it exists in the keybindings table
2. Add the key to the corresponding player's input queue
3. Set the lastInputFrame to the current frame

Every frame, the game checks if the last input happened more than FRAME_GAP frames ago. If so, then runs through the queue, adding keypresses to an input object, which it then sends to the player to be processed. Because input isn't processed every frame, it's easier to press two keys "at the same time". It doesn't matter if primary and secondary are both pressed or multiple directions are pressed because only the first one is recognized.

On a totally different note, I added a "drawQueue" for scheduling draw calls outside of love.draw(). Passing drawQueue:push() a function will cause that function to be run when the next draw phase comes around. This is really useful for debugging because it allows you to use love.graphics functions whenever you want.

### Saturday

I got the move processing system running today, finally. Not a big deal, mostly bug fixes. I'm thinking about better ways to define the moves in the character files. When we settle on something I'll post an explanation of how the system works here.

Characters are defined in this format:

    character = {
	    primary = {
		    function(player, frame), -- foreward
			function(player, frame), -- right
			function(player, frame), -- backward
			function(player, frame), -- left
			function(player, frame)  -- neutral
		},
	    secondary = {
		    function(player, frame), -- foreward
			function(player, frame), -- right
			function(player, frame), -- backward
			function(player, frame), -- left
			function(player, frame)  -- neutral
		}
	}

There are 10 different actions in each character's moveset: one in each of five directions for the both primary and secondary action buttons. Each function represents an action. The function defines what the player should do each frame when performing that action, and is composed of a sequence of function calls in the player object. For example:

    function(player, frame)
	    if frame > 32 then
		    -- Finish this action, switch to the next queued action if available
		    player:endAction()
		else
		    if frame == 0 then
			    -- Turn right relative to the player's original direction
				player:face(Direction.RIGHT)
			elseif frame == 16 then
			    -- Test for a hit at player center with radius 64, power 1
				player:hit(0, 0, 64, 1)
			elseif frame > 16 then
			    -- Move 2 pixels forward
			    player:move(Direction.FORWARD, 2)
			end
		end
	end

Player has a reference to its current action and next action and calls the current action every update step.

### Thursday

Moves are proving difficult to implement in a way that makes them easy to iterate on. Maps on the other hand, have evolved to allow for occlusion in front of the character:
1. Metadata for the map (spawn squares, walls, holes) is now stored in a separate "key" texture of the same dimensions. This allows us to define visual and gameplay properties of tiles separately
2. The game renders a second spritebatch in front of the player, which is used for occlusion. This layer is offset about -20 pixels. It represents the tops of walls, adding perspective to the top-down grid.

Hopefully we have move processing done before Sunday.

## Week 1

### Wednesday

We worked for an hour in class today. Jonas combined map and tilemap into one and implemented map loading from image files. Benji worked more on move processing, which we renamed to abilities.

### Tuesday

I worked on maps. Maps are currently a 2D array of integers. Tilemaps load a tileset from an image and divide it into individual quads for each tile. Tilemap.update feeds quads into a sprite batch in order determined by the values in the map. Tilemap.draw simply draws the sprite batch. I decided to use the spritebatch because it allows us to easily load many sprites from a single image. It also gives us a performance boost because it only draws the tiles that are on-screen (though in our game the number of tiles off-screen is negligible).

Plans:
* Combine the Map and Tilemap class.
* Load maps from an image where the color value of each pixel corresponds to the tileset index.
* Possibly make the tiles rectangular for the sake of perspective.

### Monday

We got started building the engine today, postponing the card-game idea. As a last minute change to the game design, we decided to lock the players to a grid. This makes the game's state more readable, and the results of particular moves better defined. Like we said earlier, we want the player to be able to evaluate which move would be best even from a single frame, and this should make it easier, while emphasizing the player's ability to evaluate the available moves.

Jonas has used Love2D some, but Benji has not. We started writing code right away to get up to speed with Lua, and also to create a good platform where we could test moves as soon as possible.

We got a player moving around on the screen in the new engine in about an hour and a half. Here's are plan for the rest of the week:
1. Finish the move framework by Tuesday. This includes deciding on a format for move definition that is easy to iterate on, and implementing functions in the player table that load and execute those moves.
2. Implement maps before Thursday. These can be a simple 2d array, but they should be able to display a large variation of tiles very quickly.
3. Start collision detection, physics, player/player interaction in Thursday lab or earlier. This should be easier in a grid-based system.
4. Week 2 we start defining moves and move sets. We also start creating the art and animations at this time.
5. Week 3 will be for gamepad support, sound, and front-end in addtion to the gameplay balancing and artwork that we started in Week 2.

By the end of monday we had players reading keyboard inputs from a keybindings table, but not processing them.

### Sunday

We decided to use a different game engine to make iteration faster. We picked a 2D engine because it would be easier to animate the characters in the long run, and because our game world was really only two dimensions being rendered as three, it makes the game much more readable to the player. We settled on Love2D for our engine over G3D for several reasons:
* It has everything we need built-in. Love2D has Box2D built in as well as fonts, audio, particle systems, shaders, and sprite batches for tiled backgrounds.
* It uses Lua for scripting. Lua is a very flexible language that allows for fast development iteration. It's a scripting language like Python, but it has much better performance and is closely related to C and C++. Lua's table data structure makes data declaration easy, which is important to us because we have to define so many moves.
* It's easy to setup, and we can use whatever development environment we want. All you need to do is drop a folder of scripts onto the running Love2D application window, or you can launch the application from a command-line argument.
* It has support for pixel shaders written in a modified version of GLSL. We have some ideas for this feature, more info on this later.
* It's open source, like G3D.

### Friday

We talked to Chris Perry in class today and he suggested we use a 2D game engine because all we're really doing is drawing characters on a background. We thought this was a good idea because 3D animations are hard. We decided to sleep on it.

Additionally we started thinking about how our game would work as a card game or board game. Double-blind card games in particular are a good model for fighting games because at any instant, neither player knows what input the other player just made. 



## Old Journal Entries

### Tuesday

I removed the old fence object because I couldn't figure out how to separate the different models in the file. I added a new fence, atmospheric lighting, and a prison building. I made the floor very slightly reflective. Reworks of the trailer are to come.

Set up the camera splines for the film shots.  Needed to learn how to use splines in the first place, but it turns out that they are pretty simple.  The trickiest part of it all is actually controlling the players predictably while the camera moves around, since the control directions are oriented with respect to the gameplay camera, not the the camera being used.

### Monday

I fixed the player running animation by passing the Pose constructor the game time. I also changed the scene so that it looks like its nighttime. Aside from separating the fence model, all we have to do is add the rain shader and setup the camera splines for the film.

Player animations now work correctly. I figured out that you have to set the pose of the entity to an MD2Model::Pose(MD2Model::Animation). The run animation is wonky right now because it resets the pose every frame, but it shouldn't be too hard with the help of a boolean value to check if it is already running or not. We're starting to see a bit of a framerate drop, but nothing too serious; I think the fences are hurting the performance because we haven't figured out to split up the model yet.

### Sunday

The fence model now displays the correct textures. It turns out I was setting the material to grey by mistake in the scene file, when the obj file took care of the textures and materials automatically. It seems like the .dds files are a little broken, as the semi-transparent textures are displayed with a very slight grey tint.

The player models work! It took me a long time to figure out the format in the scene file for them to work. They look pretty prisoner like without a weapon model.

After deciding which models to use, we tried to import them today. I grabbed a character model with animations from the G3D library, but it isn't implemented yet. The other model was a chainlink fence model pack, which included several different parts. The .mtl file specified the locations of the textures relative to C:\Users\Home\Desktop..., so I had to manually change them.

### Tuesday

We made the trailer today, and added the help menu as well as sounds. Not much to say other than that getting audio to work was very confusing.

### Monday

We made a lot of progress today, primarily got most of the framework that we laid down on Sunday functional. This included rotating the model and animating dashes by using our move framework. You can also queue a secondary move to happen after your current move. There are currently only dash and jab moves.

### Sunday

Our code is designed such that it is extremely easy to program new moves. There are two important classes that make this happen.

Player.cpp holds most of the logic for each player and consists of the following:

* A position vector.
* A rotation vector.
* A pointer to a scene entity.
* A pointer to the current move.
* onGraphics(): used next week for rendering the player and the effects for each move.
* onSimulation(): updates the player's position, hitboxes, hurtboxes by calling the relevant functions from the current move object (explained below).
* input(): takes several arguments from App.cpp and constructs a new move object to be initialized when the player starts the move.

Move.h is a superclass for all of the different move objects:

* Initial position, rotation, time.
* The duration of the move in seconds.
* init() sets the initial position, rotation and time when the move starts.
* toWorldSpace() converts positions and hitboxes into world space, that is, relative to the initial rotation and position.
* position(), hitbox(), hurtbox() return values in world space for the duration of the move. The player object calls these functions on its current move object to determine where it should position its model at any given time. These are made easy to conceptualize and implement for differnt move subclasses with the inclusion of toWorldSpace(). They return an infinite value when the move is over.


> \thumbnail{2014-11-04_000_interaction-fighter_r3790_g3d_r5471__Two_players.jpg, Two players}

### Saturday

The moveset available to the player varies depending on which character was chosen, but the moves fall into several easily definable categories. A player has several options for movement at any time:
1. Use the directional keys to walk around.
2. Press the attack key: the move performed depends on the moveset used, but is a generally weak but fast attack.
3. Press the defend key: this can either be a block, dodge, or some other defensive move depending on the moveset.
4. Press both a directional key and an attack or defend key: this performs a more powerful, but slower offensive or defensive move depending on the moveset, often changes the move depending on the directional key's relation to the player's facing.
5. Chain a move: if the character is already performing a move and another move is entered, a variant of the second move will occur after the first move ends. These moves can be very powerful, but are often more situational, which can allow for some creative combos.


### Thursday

> \thumbnail{2014-10-30_000_interaction-fighter_r3545_g3d_r5461__Arena.jpg, Arena}

The beginnings of our first map: Arena

### Game Design Thoughts

Dashing as a primary mechanic, providing really quick attacks and movements in short bursts.  Queueing moves to combo smoothly.

### Initial game idea

The general idea for the game is a top-down, fast-paced fighting game.  We are drawing inspiration from games such as: Super Smash Bros., Dark Souls, and Samurai Gunn.  Our vision for the gameplay is that it revolves around quick combos that rely on positioning and histuns to execute.  We aim to take advantage of the 2 degrees of freedom in movement to provide a range of different attacks.  We want the game to have a high skill ceiling while not alienating novice players.

The challenges that we anticipate are: the necessity of a highframe rate, convincing animation, and balanced gameplay.
