extends Node2D

const ACTIONS_DICT: Dictionary = {
    Vector2i.UP: "move_forward",
    Vector2i.DOWN: "move_backward",
    Vector2i.LEFT: "move_left",
    Vector2i.RIGHT: "move_right",
}

const DAS_DELAY: float = 0.28
const DAS_RATE: float = 0.058

@onready var board: TileMapLayer = $Board
@onready var active: Active = $Active

var generator: PieceMachine = PieceMachine.new()

var das_count: float = 0
var das_dir_stack: Array[Vector2i]
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
    var stack_count: int = das_dir_stack.size()

    # if new dir(s) on the stack move immediately and reset @das_repeat_count.
    _check_just_pressed()
    if das_dir_stack.size() > stack_count:
        active.move(das_dir_stack.back())
        _reset_das()
        _process_das(delta)
        return

    # no new inputs.
    # check the stack for a continued input, popping and dirs that have been lost.
    while das_dir_stack.size() > 0:
        if not Input.is_action_pressed(ACTIONS_DICT[das_dir_stack.back()]):
            das_dir_stack.pop_back()
        else:
            break

    # if there are still dirs on the stack then process DAS, otherwise we have
    # lost all inputs so reset DAS.
    if das_dir_stack.size() > 0:
        _process_das(delta)
    else:
        _reset_das()


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
    active.move(das_dir_stack.back())
    das_repeat_count = 0


func _reset_das() -> void:
    das_count = 0
    das_repeat_count = DAS_RATE
        

## Checks the movement inputs for any that were just pressed. Pushes any
## directions that were to the DAS stack.
func _check_just_pressed() -> void:
    for dir in ACTIONS_DICT:
        if Input.is_action_just_pressed(ACTIONS_DICT[dir]):
            das_dir_stack.push_back(dir)


func _handle_placement_input() -> void:
    
