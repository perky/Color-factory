-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	4
level.name		=	"The Mixer"
level.enableAllButtons = false
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_EXTEND, CMD_HORIZONTAL, CMD_VERTICAL, CMD_WAIT, CMD_LOOPIN, CMD_LOOPOUT
}
level.tutorial = "mixerandloop.png"

function level.load( l )
	l:setupWaldo( WALDO_GREEN, 4, 7, 2, LEFT )
	l:setupWaldo( WALDO_RED, 8, 7, 2, LEFT )

	l:addItem( Input, 2, 5, PAINT_RED, PAINT_YELLOW )
	l:addItem( Output, 10, 4, PAINT_ORANGE )
	l:addItem( Mixer, 8, 3 )
	l:addItem( Conveyor, 3, 1, CONVEYOR_HORIZONTAL )
end

return level
