-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	1
level.name		=	"An Introduction"
level.enableAllButtons = true
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND
}

setupWaldo( WALDO_GREEN, 4, 5, 2, UP )
setupWaldo( WALDO_RED, 8, 5, 2, UP )
removeWaldo( WALDO_BLUE )

addItem( Input, 2, 5, PAINT_RED, PAINT_GREEN, PAINT_YELLOW, PAINT_YELLOW )
addItem( Output, 10, 5, PAINT_RED )
addItem( Output, 10, 4, PAINT_YELLOW, PAINT_YELLOW, PAINT_RED, PAINT_GREEN )
addItem( Sensor, 1, 1, DETECTS_COLOR, PAINT_RED )
addItem( Conveyor, 2, 1, CONVEYOR_HORIZONTAL )
--addItem( Conveyor, 2, 2, CONVEYOR_HORIZONTAL )

return level
