class_name CubeSpawner
extends Node2D

## The delay between the tile spawning and it spawning a cube.
@export var spawn_delay: float = 1.0

var start_coords: Vector2i
var end_coords: Vector2i

var CubeScene: PackedScene = load("res://scenes/cube.tscn")
var SpawnTileFwdScene: PackedScene = load("res://scenes/spawn_tile_fwd.tscn")
#var spawn_tile_lft: PackedScene = load("res")

var anim_speed: float = 1.0

var state_queue: Array
var state_duration: float = 0.

# push duration
# push enter func, then update, then exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # TODO: probably refactor
    state_queue.push_front(_none)
    state_queue.push_front(_spawn_tiles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # check whether to transition to next state
    if state_duration <= 0 and state_duration > -PI:
        # finish the current state
        state_queue.pop_back()                      # current update
        state_queue.pop_back().call()               # current exit
        # process and enter the next state
        state_duration = state_queue.pop_back()     # next duration
        state_queue.pop_back().call()               # next enter

    # process the current state
    state_queue.back().call()
    state_duration -= delta


## Generate a new start position either on the bottom or right edge.
func _new_start_coords() -> Vector2i:
    if randi() % 2 == 0:
        return Vector2i(randi() % (GameBoard.MAX_X+1), GameBoard.MAX_Y+1)
    else:
        return Vector2i(GameBoard.MAX_X+1, randi() % (GameBoard.MAX_Y+1))


## Generate a new end position either on the left or top edge, based on @start_coords
func _new_end_coords() -> Vector2i:
    if start_coords.x > GameBoard.MAX_X:
        return Vector2i(-1, randi() % (GameBoard.MAX_Y+1))
    else:
        return Vector2i(randi() % (GameBoard.MAX_X+1), -1)


func _none() -> void:
    pass


func _spawn_tiles() -> void:
    start_coords = _new_start_coords()
    end_coords = _new_end_coords()

    var spawn_tile: SpawnTile = SpawnTileFwdScene.instantiate()
    spawn_tile.position = Coords.to_transform(start_coords)
    spawn_tile.spawn_cube.connect(_spawn_cube)

    # end tile

    add_child(spawn_tile)

    state_queue.push_front(-PI)
    state_queue.push_front(_none)
    state_queue.push_front(_process_cube)


func _spawn_cube() -> void:
    var cube: Cube = CubeScene.instantiate()
    cube.position = Coords.to_transform(start_coords)
    cube.start_tile = start_coords
    cube.end_tile = end_coords

    add_child(cube)


func _process_cube() -> void:
    pass
