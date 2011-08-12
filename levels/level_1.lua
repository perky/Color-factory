local level = {}
level.number	=	1
level.name		=	"An Introduction"

setupWaldo( WALDO_GREEN, 4, 5, 2, UP )
setupWaldo( WALDO_RED, 7, 5, 2, UP )
removeWaldo( WALDO_BLUE )


addItem( InputOutput, 2, 5, IO_IN )
addItem( InputOutput, 6, 5, IO_OUT, DETECTS_COLOR, PAINT_RED )

return level
