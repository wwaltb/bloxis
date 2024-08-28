extends Node
## This class keeps track of the state of the game board.
##
## Holds a dictionary of the current tiles, keyed by their cell position. Also
## gives the bounds of the board.

const MAX_X: int = 9
const MAX_Y: int = 9

var current_tiles: Dictionary

# add board bounds here

func add_piece(piece: Piece) -> void:
    for i in range(piece.size):
        var road: Road = piece.roads[i]
        var cell: Vector2i = piece.position + piece.cells[i]
        current_tiles[cell] = road


