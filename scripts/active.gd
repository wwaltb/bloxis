class_name Active
extends TileMapLayer

var piece: Piece ## The active piece. Parent should keep this updated.


## Draws @piece to the active layer.
func draw() -> void:
    for i in range(piece.size):
        var road: Road = piece.roads[i]
        var cell: Vector2i = piece.position + piece.cells[i]
        set_cell(cell, road.get_id(), road.get_atlas_coords())


## Calls rotate_left() for @piece. If the new position is out of bounds
## rotates back.
func rotate_left() -> void:
    piece.rotate_left()
    # invalid rotation
    if piece.is_out_of_bounds():
        piece.rotate_right()


## Calls rotate_right() for @piece. If the new position is out of bounds
## rotates back.
func rotate_right() -> void:
    piece.rotate_right()
    # invalid rotation
    if piece.is_out_of_bounds():
        piece.rotate_left()


func move(dir: Vector2i) -> void:
    piece.position += dir
    # invalid movement
    if piece.is_out_of_bounds():
        piece.position -= dir


func _ready() -> void:
    pass


func _process(_delta: float) -> void:
    pass
