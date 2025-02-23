extends Node
## This class keeps track of the state of the game board.
##
## Holds a dictionary of the current tiles, keyed by their cell position. Also
## gives the bounds of the board.

enum Tiles { VOID, GRID, START, END }

const MAX_X: int = 9
const MAX_Y: int = 9

var current_tiles: Dictionary


func _ready() -> void:
    _init_board()


func _init_board() -> void:
    # init grid
    for y in range(MAX_Y + 1):
        for x in range(MAX_X + 1):
            current_tiles[Vector2i(x, y)] = Tiles.GRID
    # init empty tiles outside of grid
    for y in range(-1, MAX_Y + 2):
        current_tiles[Vector2i(-1, y)] = Tiles.VOID
        current_tiles[Vector2i(MAX_X + 1, y)] = Tiles.VOID
    for x in range(-1, MAX_X + 2):
        current_tiles[Vector2i(x, -1)] = Tiles.VOID
        current_tiles[Vector2i(x, MAX_Y + 1)] = Tiles.VOID


func add_piece(piece: Piece) -> void:
    for i in range(piece.size):
        var tile: PieceTile = piece.tiles[i]
        var cell: Vector2i = piece.position + piece.cells[i]
        current_tiles[cell] = tile
