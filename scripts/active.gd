class_name Active
extends TileMapLayer

var piece: Piece  ## The active piece. Parent should keep this updated.
var indicator: PieceIndicator


func clearPieceAndIndicator() -> void:
    clear()
    indicator.clear()


## Draws @piece to the active layer.
func drawPieceAndIndicator() -> void:
    for i in range(piece.size):
        var tile: PieceTile = piece.tiles[i]
        var cell: Vector2i = piece.position + piece.cells[i]
        set_cell(cell, tile.get_id(), tile.get_atlas_coords())
    indicator.draw()


func drawOutline() -> void:
    for i in range(piece.size):
        var cell: Vector2i = piece.position + piece.cells[i]
        set_cell(cell, 0, Vector2i(0, 0))


## Calls rotate_left() for @piece. If the new position is out of bounds
## rotates back.
func rotate_left() -> void:
    piece.rotate_left()
    # invalid rotation
    if piece.is_out_of_bounds():
        piece.rotate_right()
    else:
        indicator.rotate_indicator()


## Calls rotate_right() for @piece. If the new position is out of bounds
## rotates back.
func rotate_right() -> void:
    piece.rotate_right()
    # invalid rotation
    if piece.is_out_of_bounds():
        piece.rotate_left()
    else:
        indicator.rotate_indicator()


func move(dir: Vector2i) -> void:
    piece.position += dir
    # invalid movement
    if piece.is_out_of_bounds():
        piece.position -= dir
    else:
        indicator.move_indicator(dir)


func _ready() -> void:
    pass


func _process(_delta: float) -> void:
    pass
