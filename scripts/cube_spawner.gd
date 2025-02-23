class_name CubeSpawner
extends Node2D

## The delay between the tile spawning and it spawning a cube.
@export var spawn_delay: float = 1.0

var start_coords: Vector2i
var end_coords: Vector2i

var CubeScene: PackedScene = load("res://scenes/cube.tscn")
var SpawnTileFwdScene: PackedScene = load("res://scenes/spawn_tile_fwd.tscn")
var SpawnTileLeftScene: PackedScene = load("res://scenes/spawn_tile_left.tscn")
var EndTileScene: PackedScene = load("res://scenes/end_tile.tscn")

var cube: Cube
var spawn_tile: SpawnTile
var end_tile: EndTile

var anim_speed: float = 1.0

## push state values in order: duration, enter func, update func, exit func
var state_queue: Array
var state_duration: float = 0.


func _ready() -> void:
	# TODO: probably refactor
	# push the current update to be popped
	state_queue.push_front(_none)
	# push an exit function which pushes the first state
	state_queue.push_front(_spawn_tiles)


func _process(delta: float) -> void:
	# check whether to transition to next state
	if state_duration <= 0 and state_duration > -PI:
		# finish the current state
		state_queue.pop_back()  # current update
		state_queue.pop_back().call()  # current exit
		# process and enter the next state
		state_duration = state_queue.pop_back()  # next duration
		state_queue.pop_back().call()  # next enter

	# process the current state
	state_queue.back().call()
	state_duration -= delta


## Generate a new start position either on the bottom or right edge.
func _new_start_coords() -> Vector2i:
	if randi() % 2 == 0:
		return Vector2i(randi() % (GameBoard.MAX_X + 1), GameBoard.MAX_Y + 1)
	else:
		return Vector2i(GameBoard.MAX_X + 1, randi() % (GameBoard.MAX_Y + 1))


## Generate a new end position either on the left or top edge, based on @start_coords
func _new_end_coords() -> Vector2i:
	if start_coords.x > GameBoard.MAX_X:
		return Vector2i(-1, randi() % (GameBoard.MAX_Y + 1))
	else:
		return Vector2i(randi() % (GameBoard.MAX_X + 1), -1)


func _none() -> void:
	pass


## spawn the start and end tile and then idle until the cube is despawned
func _spawn_tiles() -> void:
	if start_coords != null:
		GameBoard.current_tiles[start_coords] = GameBoard.Tiles.VOID
	start_coords = _new_start_coords()
	GameBoard.current_tiles[start_coords] = GameBoard.Tiles.START

	if start_coords.x > GameBoard.MAX_X:
		spawn_tile = SpawnTileLeftScene.instantiate()
	else:
		spawn_tile = SpawnTileFwdScene.instantiate()

	spawn_tile.spawn_delay = spawn_delay
	spawn_tile.position = Coords.to_transform(start_coords)
	spawn_tile.spawn_cube.connect(_spawn_cube)
	add_child(spawn_tile)

	# end tile
	if end_coords != null:
		GameBoard.current_tiles[end_coords] = GameBoard.Tiles.VOID
	end_coords = _new_end_coords()
	GameBoard.current_tiles[end_coords] = GameBoard.Tiles.END

	end_tile = EndTileScene.instantiate()
	end_tile.position = Coords.to_transform(end_coords)
	add_child(end_tile)

	state_queue.push_front(-PI)
	state_queue.push_front(_none)
	state_queue.push_front(_none)
	state_queue.push_front(_despawn_tiles)


func _spawn_cube() -> void:
	cube = CubeScene.instantiate()
	cube.position = Coords.to_transform(start_coords)
	cube.start_tile = start_coords
	cube.end_tile = end_coords
	cube.despawned.connect(_process_cube_exit)

	add_child(cube)


func _process_cube_exit() -> void:
	state_duration = spawn_delay


func _despawn_tiles() -> void:
	# spawn and end tiles are waiting to despawn, so force a state change
	spawn_tile.anim_duration = 0
	end_tile.anim_duration = 0

	# TODO: add gameover logic when ready
	state_queue.push_front(2)
	state_queue.push_front(_none)
	state_queue.push_front(_none)
	state_queue.push_front(_spawn_tiles)
