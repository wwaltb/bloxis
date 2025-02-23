class_name PieceIndicator
extends TileMapLayer

const ATLAS_COORDS_HASH: Dictionary = {
    Compass.N: Vector2i(0, 0),
    Compass.S: Vector2i(0, 0),
    Compass.E: Vector2i(1, 0),
    Compass.W: Vector2i(1, 0),
}

var cell: Vector2i
var dir: int


func draw() -> void:
    set_cell(cell, 0, ATLAS_COORDS_HASH[dir])


func rotate_indicator() -> void:
    dir = Compass.get_rotate_90(dir)


func move_indicator(move_dir: Vector2i) -> void:
    cell += move_dir
