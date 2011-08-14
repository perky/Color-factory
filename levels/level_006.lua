-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	6
level.name		=	"I'm not sure if this is even solvable"
level.enableAllButtons = true
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND, CMD_HORIZONTAL, CMD_VERTICAL, CMD_WAIT, CMD_LOOP
}

function level.load()
	setupWaldo( WALDO_GREEN, 4, 7, 2, LEFT )
	setupWaldo( WALDO_RED, 8, 7, 2, LEFT )

	addItem( Input, 4, 2, PAINT_RED, PAINT_RED, PAINT_BLUE, PAINT_BLUE )
	addItem( Input, 4, 3, PAINT_YELLOW, PAINT_YELLOW, PAINT_BLUE, PAINT_BLUE )
	addItem( Output, 10, 4, PAINT_ORANGE, PAINT_ORANGE, PAINT_BLUE, PAINT_BLUE )
	addItem( Output, 10, 5, PAINT_BLUE )
	addItem( Mixer, 6, 3 )
	addItem( Boxer, 9, 3 )
	addItem( Sensor, 8, 3, PAINT_BLUE )
	addItem( Sensor, 7, 3, PAINT_RED )
end

return level
