class_name PieceTile
extends RefCounted
# ! Old code, but could possibly reuse for tiles, maybe just treat straight tiles as blank ones
## Keeps track of the directions each tile points and which sprite they are
##
## Uses @from and @to to track the directions the tile points. @get_id() and
## @get_atlas_coords() provide the id and coordinates for the tile's sprite.

const TILE_ID: int = 1
const TILE_ATLAS: Dictionary = {
    Compass.N: {
        Compass.E: Vector2i(2, 0),
        Compass.S: Vector2i(0, 0),
        Compass.W: Vector2i(1, 0),
    },
    Compass.E: {
        Compass.N: Vector2i(4, 0),
        Compass.S: Vector2i(3, 0),
        Compass.W: Vector2i(0, 0),
    },
    Compass.S: {
        Compass.N: Vector2i(0, 0),
        Compass.E: Vector2i(2, 0),
        Compass.W: Vector2i(1, 0),
    },
    Compass.W: {
        Compass.N: Vector2i(4, 0),
        Compass.E: Vector2i(0, 0),
        Compass.S: Vector2i(3, 0),
    },
}

var from: int   ## The direction this tile comes from
var to: int     ## The direction this tile goes to


## Returns the tile's tileset id.
func get_id() -> int:
    return TILE_ID


## Returns the tileset atlas coordinates for the tile's sprite.
func get_atlas_coords() -> Vector2i:
    return TILE_ATLAS[from][to]


## Generates a new random tile. If @prev tile is given the new tile will
## connect to it.

## Creates a new tile with random directions unless given through @f and/or @t
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
