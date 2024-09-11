extends AnimatedSprite2D

const GRID_OFFSET: Vector2i = Vector2i(24, 12)

var grid_position: Vector2i = Vector2i(0, 0)
var start_tile: Vector2i = Vector2i(0, 10)
var end_tile: Vector2i = Vector2i(9, -1)

var anim_speed: float = 1.0

var time: float = 0.0

var anim_queue: Array[StringName]

var anim_exit_funcs: Dictionary = {
    "dying": Callable(self, "_dying_exit"),
    "idle": Callable(self, "_idle_exit"),
    "moving_backward": Callable(self, "_moving_exit"),
    "moving_forward": Callable(self, "_moving_exit"),
    "moving_left": Callable(self, "_moving_exit"),
    "moving_right": Callable(self, "_moving_exit"),
    "spawning": Callable(self, "_spawning_exit"),
}

var moving_vectors: Dictionary = {
    "moving_backward": Vector2(-24, 12),
    "moving_forward": Vector2(24, -12),
    "moving_left": Vector2(-24, -12),
    "moving_right": Vector2(24, 12),
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
    play("spawning")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if not is_playing():
        anim_exit_funcs[animation].call()
        if anim_queue.is_empty():
            return
        play(anim_queue.pop_back())

    position = GRID_OFFSET

    if grid_position.x > 0:
        position += grid_position.x * moving_vectors["moving_right"]
    else:
        position += grid_position.x * moving_vectors["moving_left"]

    if grid_position.y > 0:
        position += grid_position.y * moving_vectors["moving_backward"]
    else:
        position += grid_position.y * moving_vectors["moving_forward"]


func _moving_exit() -> void:
    grid_position += Compass.get_vector2i(moving_dirs[animation])
    # TODO: refactor the gameboard dictionary to include all tiles in and
    # around the board, so we can reference that for all tile information
    if grid_position == end_tile:
        anim_queue.push_front("idle")
        anim_queue.push_front("despawning")
        return

    if not GameBoard.current_tiles.has(grid_position):
        anim_queue.push_front("dying")
        return

    var dest_tile: Road = GameBoard.current_tiles[grid_position]

    if dest_tile.to == Compass.get_rotate_180(dest_tile.from):
        anim_queue.push_front("idle")
        anim_queue.push_front(animation)
    else:
        anim_queue.push_front("idle")
        anim_queue.push_front(moving_dirs[dest_tile.to])


func _dying_exit() -> void:
    queue_free()


func _idle_exit() -> void:
    pass


func _spawning_exit() -> void:
    print("hello")
    anim_queue.push_front("idle")
    if start_tile.x > GameBoard.MAX_X:
        anim_queue.push_front("moving_left")
    else:
        anim_queue.push_front("moving_forward")
