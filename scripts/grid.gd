extends TileMapLayer

const GRID_SOURCE: int = 0

const ATLAS_COORDS: Dictionary = {
    "": Vector2i(0, 0),
    "E": Vector2i(2, 0),
    "N": Vector2i(0, 2),
    "NE": Vector2i(2, 1),
    "NW": Vector2i(1, 2),
    "S": Vector2i(0, 1),
    "SE": Vector2i(1, 1),
    "SW": Vector2i(1, 0),
    "W": Vector2i(2, 2),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for y in range(GameBoard.MAX_Y + 1):
        var y_name: String = ""
        if y == GameBoard.MAX_Y:
            y_name += "N"
        if y == 0:
            y_name += "S"
        for x in range(GameBoard.MAX_X + 1):
            var x_name: String = ""
            if x == GameBoard.MAX_X:
                x_name += "W"
            if x == 0:
                x_name += "E"

            set_cell(Vector2i(x, y), GRID_SOURCE, ATLAS_COORDS[y_name + x_name])
