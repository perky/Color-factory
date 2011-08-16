-- This is a level file, it describes the level.
-- Lines with double dashes are a comment, they are ignored by the game.
local level = {}
level.number	=	1
level.name		=	"An Introduction"
level.enableAllButtons = false
level.enabledButtons = {
	CMD_ROTATE_CW, CMD_ROTATE_CCW, CMD_GRABDROP, CMD_INPUT, CMD_OUTPUT
}
level.tutorial = "introduction.png"

function level.load( l )
	l:setupWaldo( WALDO_GREEN, 3, 1, 2, LEFT )
	l:setupWaldo( WALDO_RED, 8, 5, 2, LEFT )

	l:addItem( Input, 6, 5, PAINT_RED, PAINT_RED, PAINT_RED, PAINT_RED )
	l:addItem( Output, 10, 5, PAINT_RED )
end

return level
