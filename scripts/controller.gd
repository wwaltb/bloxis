extends Node2D

const ACTIONS_DICT: Dictionary = {
    Vector2i.UP: "move_forward",
    Vector2i.DOWN: "move_backward",
    Vector2i.LEFT: "move_left",
    Vector2i.RIGHT: "move_right",
}

const DAS_DELAY: float = 0.28
const DAS_RATE: float = 0.058

@onready var board: Board = $Board
@onready var active_piece: Active = $Active
@onready var active_outline: Active = $ActiveOutline
@onready var active_indicator: PieceIndicator = $PieceIndicator

var generator: PieceMachine = PieceMachine.new()

var das_count: float = 0
var das_dir_stack: Array[Vector2i]
var das_repeat_count: float = DAS_RATE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _update_pieces()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # clear active_piece piece sprites
    active_outline.clear()
    active_piece.clearPieceAndIndicator()

    # update placeable indication colors
    if active_piece.piece.is_placeable():
        active_outline.alternative = 0
        active_indicator.alternative = 0
    else:
        active_outline.alternative = 1
        active_indicator.alternative = 2

    # handle inputs
    _handle_movement_input(delta)
    _handle_rotation_input()
    _handle_placement_input()

    active_outline.drawOutline()
    active_piece.drawPieceAndIndicator()


func _update_pieces() -> void:
    # get the next active piece and update it's position
    var new: Piece = generator.active()
    var x: int = roundi(float(GameBoard.MAX_X) / 2)
    var y: int = roundi(float(GameBoard.MAX_Y) / 2)
    new.position = Vector2i(x, y)

    # update our active piece tile map layers to use the new piece
    active_piece.piece = new
    active_piece.indicator = active_indicator

    active_outline.piece = new
    active_outline.indicator = active_indicator

    if active_piece.piece.size == 1:
        active_indicator.cell = active_piece.piece.position + active_piece.piece.cells[0]
        active_indicator.dir = active_piece.piece.tiles[0].to
    else:
        active_indicator.cell = active_piece.piece.position + active_piece.piece.cells[1]
        active_indicator.dir = active_piece.piece.tiles[1].to


func _handle_rotation_input() -> void:
    if Input.is_action_just_pressed("rotate_left"):
        active_piece.rotate_left()
    if Input.is_action_just_pressed("rotate_right"):
        active_piece.rotate_right()


func _handle_movement_input(delta: float) -> void:
    var stack_count: int = das_dir_stack.size()

    # if new dir(s) on the stack move immediately and reset @das_repeat_count.
    _check_just_pressed()
    if das_dir_stack.size() > stack_count:
        active_piece.move(das_dir_stack.back())
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
    active_piece.move(das_dir_stack.back())
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
    if not Input.is_action_just_pressed("place"):
        return
    if not active_piece.piece.is_placeable():
        return

    # TODO: board should contain the gameboard current pieces object
    GameBoard.add_piece(active_piece.piece)
    board.draw(active_piece.piece)
    generator.new_piece()
    _update_pieces()
