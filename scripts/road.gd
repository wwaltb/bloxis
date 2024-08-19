class_name Road
extends RefCounted
## Keeps track of the directions each road points and which sprite they are
##
## Uses @from and @to to track the directions the road points. @get_id() and
## @get_atlas_coords() provide the id and coordinates for the road's sprite.

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
}

var from: int   ## The direction this road comes from
var to: int     ## The direction this road goes to


## Returns the road's tileset id.
func get_id() -> int:
    return ROAD_ID


## Returns the tileset atlas coordinates for the road's sprite.
func get_atlas_coords() -> Vector2i:
    return ROAD_ATLAS[from][to]


## Generates a new random road. If @prev road is given the new road will
## connect to it.

## Creates a new road with random directions unless given through @f and/or @t
func _init(f: int = -1, t: int = -1) -> void:
    # try to assign @to and @from based on @t and @f
    if f >= 0:
        from = f
    if t >= 0:
        to = t
    # t is given but f is not
    if t >= 0 and f < 0:
        from = Compass.get_random_other_than(to)
    # finally just if f is not given
    elif f < 0:
        from = Compass.get_random()
    # ensure @to is different than @from
    if t < 0 or t == f:
        to = Compass.get_random_other_than(from)
