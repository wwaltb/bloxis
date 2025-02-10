class_name Cube
extends AnimatedSprite2D

signal despawned

var grid_position: Vector2i = Vector2i(0, 0)
var start_tile: Vector2i
var end_tile: Vector2i

var anim_speed: float = 1.0

var anim_queue: Array[StringName]

var anim_exit_funcs: Dictionary = {
    "dying": Callable(self, "_dying_exit"),
    "idle": Callable(self, "_idle_exit"),
    "moving_backward": Callable(self, "_moving_exit"),
    "moving_forward": Callable(self, "_moving_exit"),
    "moving_left": Callable(self, "_moving_exit"),
    "moving_right": Callable(self, "_moving_exit"),
    "spawning": Callable(self, "_spawning_exit"),
    "despawning": Callable(self, "_despawning_exit")
}

var moving_dirs: Dictionary = {
    "moving_backward": Compass.N,
    "moving_forward": Compass.S,
    "moving_left": Compass.E,
    "moving_right": Compass.W,
    Compass.N: "moving_backward",
    Compass.S: "moving_forward",
    Compass.E: "moving_left",
    Compass.W: "moving_right",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    grid_position = start_tile
    play("spawning", anim_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if not is_playing():
        anim_exit_funcs[animation].call()
        if anim_queue.is_empty():
            return
        play(anim_queue.pop_back(), anim_speed)

    position = Coords.to_transform(grid_position)

func _moving_exit() -> void:
    grid_position += Compass.get_vector2i(moving_dirs[animation])
    # TODO: refactor the gameboard dictionary to include all tiles in and
    # around the board, so we can reference that for all tile information
    if typeof(GameBoard.current_tiles[grid_position]) == TYPE_OBJECT:
        var dest_tile: Road = GameBoard.current_tiles[grid_position]
    
        if dest_tile.to == Compass.get_rotate_180(dest_tile.from):
            anim_queue.push_front("idle")
            anim_queue.push_front(animation)
        else:
            anim_queue.push_front("idle")
            anim_queue.push_front(moving_dirs[dest_tile.to])

        return
    
    if GameBoard.current_tiles[grid_position] == GameBoard.Tiles.END:
        anim_queue.push_front("idle")
        anim_queue.push_front("despawning")
        return

    if GameBoard.current_tiles[grid_position] == GameBoard.Tiles.VOID:
        anim_queue.push_front("dying")
        return

    if GameBoard.current_tiles[grid_position] == GameBoard.Tiles.GRID:
        anim_queue.push_front("dying")
        return


func _dying_exit() -> void:
    despawned.emit()
    queue_free()


func _despawning_exit() -> void:
    despawned.emit()
    queue_free()


func _idle_exit() -> void:
    pass


func _spawning_exit() -> void:
    anim_queue.push_front("idle")
    if start_tile.x > GameBoard.MAX_X:
        anim_queue.push_front("moving_left")
    else:
        anim_queue.push_front("moving_forward")
