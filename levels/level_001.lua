-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	1
level.name		=	"An Introduction"
level.enableAllButtons = false
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_HORIZONTAL, CMD_VERTICAL, CMD_WAIT, CMD_LOOP, CMD_INPUT, CMD_OUTPUT
}

function level.load()
	setupWaldo( WALDO_GREEN, 4, 5, 2, LEFT )
	setupWaldo( WALDO_RED, 8, 5, 2, LEFT )

	addItem( Input, 2, 5, PAINT_RED, PAINT_GREEN, PAINT_YELLOW, PAINT_YELLOW )
	addItem( Output, 10, 5, PAINT_RED )
	addItem( Output, 10, 4, PAINT_YELLOW, PAINT_YELLOW, PAINT_RED, PAINT_GREEN )
	--addItem( Sensor, 1, 1, DETECTS_COLOR, PAINT_RED )
	--addItem( Conveyor, 2, 1, CONVEYOR_HORIZONTAL )
	addItem( Boxer, 3, 3 )
	--addItem( Conveyor, 2, 2, CONVEYOR_HORIZONTAL )
end

return level
