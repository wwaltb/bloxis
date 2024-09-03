extends Node

const DAS_DELAY = 0.28
const DAS_RATE = 0.05

@onready var board: TileMapLayer = $Board
@onready var active: Active = $Active

var generator: PieceMachine = PieceMachine.new()

var das_count: float = 0
var das_dir: Vector2i = Vector2i.ZERO
var das_repeat_count: float = DAS_RATE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _update_pieces()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    active.clear()
    _handle_rotation_input()
    _handle_movement_input(delta)
    active.draw()


func _update_pieces() -> void:
    active.piece = generator.active()


func _handle_rotation_input() -> void:
    if Input.is_action_just_pressed("rotate_left"):
        active.rotate_left()
    if Input.is_action_just_pressed("rotate_right"):
        active.rotate_right()


func _handle_movement_input(delta: float) -> void:
    # reset DAS and move if any new inputs
    if _check_just_pressed() != Vector2i.ZERO:
        _reset_das()
        das_dir = _check_just_pressed()
        active.move(das_dir)
        return

    # no new inputs:
    # reset DAS if old input is not preserved and return
    match das_dir:
        Vector2i.UP:
            if not Input.is_action_pressed("move_forward"):
                _reset_das()
                return
        Vector2i.DOWN:
            if not Input.is_action_pressed("move_backward"):
                _reset_das()
                return
        Vector2i.LEFT:
            if not Input.is_action_pressed("move_left"):
                _reset_das()
                return
        Vector2i.RIGHT:
            if not Input.is_action_pressed("move_right"):
                _reset_das()
                return
        _:
            pass

    # continued input:
    _process_das(delta)


func _process_das(delta: float) -> void:
    das_count += delta
    # nothing left to do if DAS is not activated:
    if das_count < DAS_DELAY:
        return

    das_repeat_count += delta
    # nothing left to do if DAS is not on a "tick"
    if das_repeat_count < DAS_RATE:
        return

    # DAS is activated and should move the piece:
    active.move(das_dir)
    das_repeat_count = 0


func _reset_das() -> void:
    das_count = 0
    das_dir = Vector2i.ZERO
    das_repeat_count = DAS_RATE
        

## Checks the movement inputs for any that were just pressed. Returns the
## vector of a just pressed direction or Vector21.ZERO if none were.
func _check_just_pressed() -> Vector2i:
    if Input.is_action_just_pressed("move_forward"):
        return Vector2i.UP
    if Input.is_action_just_pressed("move_backward"):
        return Vector2i.DOWN
    if Input.is_action_just_pressed("move_left"):
        return Vector2i.LEFT
    if Input.is_action_just_pressed("move_right"):
        return Vector2i.RIGHT
    return Vector2i.ZERO
