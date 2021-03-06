-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	6
level.name		=	"Pure garbage"
level.enableAllButtons = true
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND, CMD_HORIZONTAL, CMD_VERTICAL, CMD_WAIT, CMD_LOOPIN, CMD_LOOPOUT
}

function level.load( l )
	-- setupWaldo( waldo color, x position, y position, length, default orientation )
	l:setupWaldo( WALDO_GREEN, 4, 7, 2, LEFT )
	l:setupWaldo( WALDO_RED, 8, 7, 2, LEFT )
	
	-- addItem( item name, x position, y position, other variables )
	-- Inputs have four slots that are used for the randomization of paint input.
	-- The example below will input 50% red and 50% blue.
	l:addItem( Input, 4, 2, PAINT_RED, PAINT_RED, PAINT_BLUE, PAINT_BLUE )
	-- Outputs also have four slots, using more then one slot will indicate that it outputs a box.
	l:addItem( Output, 10, 4, PAINT_PURPLE, PAINT_PURPLE )
	-- Outputs that only use up one slot only accept individual paint tins.
	l:addItem( Output, 10, 2, PAINT_ANY )
	l:addItem( Mixer, 6, 3 )
	l:addItem( Boxer, 9, 3 )
	l:addItem( Sensor, 7, 3, PAINT_RED )
	l:addItem( Conveyor, 3, 1, CONVEYOR_HORIZONTAL )
end

return level
