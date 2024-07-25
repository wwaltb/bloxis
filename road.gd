class_name Road
extends RefCounted

const ROAD_ID: int = 11
const ROAD_ATLAS: Dictionary = {
    Compass.N: {
        Compass.E: Vector2i(9, 0),
        Compass.S: Vector2i(6, 0),
        Compass.W: Vector2i(10, 0),
    },
    Compass.E: {
        Compass.N: Vector2i(9, 0),
        Compass.S: Vector2i(7, 0),
        Compass.W: Vector2i(8, 0),
    },
    Compass.S: {
        Compass.N: Vector2i(6, 0),
        Compass.E: Vector2i(7, 0),
        Compass.W: Vector2i(5, 0),
    },
    Compass.W: {
        Compass.N: Vector2i(10, 0),
        Compass.E: Vector2i(8, 0),
        Compass.S: Vector2i(5, 0),
    },
    "NE": Vector2i(9, 0),
    "NS": Vector2i(6, 0),
    "NW": Vector2i(10, 0),
    "EN": Vector2i(9, 0),
    "ES": Vector2i(7, 0),
    "EW": Vector2i(8, 0),
    "SN": Vector2i(6, 0),
    "SE": Vector2i(7, 0),
    "SW": Vector2i(5, 0),
    "WN": Vector2i(10, 0),
    "WE": Vector2i(8, 0),
    "WS": Vector2i(5, 0)
}

var from: int ## The direction this road comes from
var to: int ## The direction this road goes to

## Generates a new road. If @prev road is given the new road will connect to
## it.
func _init(prev: Road = null) -> void:
    # generate from direction
    if prev:
        from = Compass.get_rotate_180(prev.to)
    else:
        from = Compass.get_random()
    # generate to direction
    to = Compass.get_random_other_than(from)

# get road id
func get_id() -> int:
    return ROAD_ID

# get road atlas coords
func get_atlas_coords() -> Vector2i:
    return ROAD_ATLAS[from][to]
