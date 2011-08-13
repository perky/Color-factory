-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	1
level.name		=	"An Introduction"
level.enableAllButtons = false
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND
}

setupWaldo( WALDO_GREEN, 4, 5, 2, UP )
setupWaldo( WALDO_RED, 8, 5, 2, UP )
removeWaldo( WALDO_BLUE )

addItem( InputOutput, 2, 5, IO_IN )
addItem( InputOutput, 10, 5, IO_OUT, DETECTS_COLOR, PAINT_RED )
addItem( InputOutput, 10, 4, IO_OUT, DETECTS_COLOR, PAINT_YELLOW)
addItem( Sensor, 1, 1, DETECTS_COLOR, PAINT_RED )

return level
