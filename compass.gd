extends Node

const NUM_DIRS = 4

## Cardinal directions
enum {
    N,  ## North
    E,  ## East
    S,  ## South
    W   ## West
}

## returns a random direction
func get_random() -> int:
    return randi() % NUM_DIRS

## returns a random direction other than @dir
func get_random_other_than(dir: int) -> int:
    return (dir + randi() % 3) % NUM_DIRS

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
