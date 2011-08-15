-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.custom	=	true
-- The name will show up in the menu along with the author.
level.name		=	"Custom level template"
level.author   =  "Luke Perkin"
-- You can enter a list of buttons to enable.
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND, CMD_HORIZONTAL, CMD_VERTICAL, CMD_WAIT, CMD_SENSE, CMD_JUMP, CMD_JUMPOUT, CMD_LOOPIN, CMD_LOOPOUT
}
-- If you're too lazy to add all the buttons to the list just set this to true.
level.enableAllButtons = false

function level.load()
   -- The setupWaldo method has the following arguments:
   -- Waldo color, x position, y position, default length, default orientation
   -- Other orientations are UP, DOWN and RIGHT.
   setupWaldo( WALDO_RED, 8, 5, 2, LEFT )
	setupWaldo( WALDO_GREEN, 3, 1, 2, LEFT )
   
   -- Inputs have four slots that are used for the randomization of paint input.
	-- The example below will input 50% red and 50% blue.
	addItem( Input, 6, 5, PAINT_RED, PAINT_RED, PAINT_BLUE, PAINT_BLUE )
	-- This input is 25% green and 75% orange.
	addItem( Input, 6, 6, PAINT_GREEN, PAINT_ORANGE, PAINT_ORANGE, PAINT_ORANGE )
	-- Outputs with a single color will accept a paint tin of that color.
	addItem( Output, 10, 5, PAINT_RED )
	-- Outputs with more than a single color will accept boxes with the specified paints.
	addItem( Output, 10, 6, PAINT_RED, PAINT_GREEN, PAINT_BLUE, PAINT_YELLOW )
	-- PAINT_ANY will accept any colored paint, this also works for sensors.
	addItem( Output, 10, 7, PAINT_ANY )
	
	-- Mixers and Boxers have no extra arguments.
	addItem( Mixer, 6, 3 )
	addItem( Boxer, 9, 3 )
	
	-- Sensors have one extra argument, the color it detects.
	addItem( Sensor, 7, 3, PAINT_RED )
	
	-- Conveyors have one extra argument, the default orientation.
	-- The other orientation is CONVEYOR_VERTICAL
	addItem( Conveyor, 3, 1, CONVEYOR_HORIZONTAL )
end

return level
