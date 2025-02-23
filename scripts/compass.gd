extends Node
## Use this class when dealing with the tilemap cardinal directions
##
## Provides direction constants @N, @E, @S, @W and the functions needed to
## interact with directions like a compass.

const NUM_DIRS = 4

## Cardinal directions
enum { N, E, S, W }


## returns a random direction
func get_random() -> int:
    return randi() % NUM_DIRS


## returns a random direction other than @dir
func get_random_other_than(dir: int) -> int:
    var rand_offset = 1 + randi() % (NUM_DIRS - 1)
    var other = (dir + rand_offset) % NUM_DIRS
    return other


## returns the vector corresponding to a compass direction
func get_vector2i(dir: int) -> Vector2i:
    match dir:
        N:
            return Vector2i.DOWN
        E:
            return Vector2i.LEFT
        S:
            return Vector2i.UP
        W:
            return Vector2i.RIGHT
        _:
            return Vector2i.ZERO


## returns the direction 90 degrees clockwise
func get_rotate_90(dir: int) -> int:
    return (dir + 1) % NUM_DIRS


## returns the direction 180 degrees clockwise
func get_rotate_180(dir: int) -> int:
    return (dir + 2) % NUM_DIRS


## returns the direction 270 degrees clockwise
func get_rotate_270(dir: int) -> int:
    return (dir + 3) % NUM_DIRS
