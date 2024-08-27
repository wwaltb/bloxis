class_name GroundMap
extends TileMap

const DAS_DELAY = 0.28
const DAS_RATE = 0.05

var das_count = 0;
var das_repeat_count = DAS_RATE
var move_dir: Vector2i = Vector2i.ZERO
var input_dir: Vector2i = Vector2i.ZERO

var piece_machine: PieceMachine = PieceMachine.new()

var current_roads: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _new_active_piece()
    _draw_piece(piece_machine.active(), 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    _update_active_piece(delta)


func _handle_movement(delta: float) -> void:
    move_dir = Vector2i.ZERO
    input_dir = Vector2i.ZERO
    # set move if input is just pressed
    if Input.is_action_just_pressed("move_forward"):
        move_dir.y += -1
        das_count = 0

    if Input.is_action_just_pressed("move_backward"):
        move_dir.y += 1
        das_count = 0

    if Input.is_action_just_pressed("move_left"):
        move_dir.x += -1
        das_count = 0

    if Input.is_action_just_pressed("move_right"):
        move_dir.x += 1
        das_count = 0

    # set input dir if input is being held
    # Input.get_vector() is not registering diagonal presses
    if Input.is_action_pressed("move_forward"):
        input_dir.y += -1

    if Input.is_action_pressed("move_backward"):
        input_dir.y += 1

    if Input.is_action_pressed("move_left"):
        input_dir.x += -1

    if Input.is_action_pressed("move_right"):
        input_dir.x += 1


    # increment das counter when input_dir is nonzero
    if input_dir:
        das_count += delta
    else:
        das_count = 0
        

func _handle_rotation() -> void:
    if Input.is_action_just_pressed("rotate_left"):
        piece_machine.active().rotate_left()
        # check if rotation was invalid
        if _is_piece_out_of_bounds():
            piece_machine.active().rotate_right()
    
    if Input.is_action_just_pressed("rotate_right"):
        piece_machine.active().rotate_right()
        # check if rotation was invalid
        if _is_piece_out_of_bounds():
            piece_machine.active().rotate_left()


func _handle_placement() -> void:
    if Input.is_action_just_pressed("place"):
        if _is_piece_placeable():
            _place_piece()


## Handles piece controlling inputs and update the active piece accordingly.
func _update_active_piece(delta: float) -> void:
    _clear_piece(piece_machine.active(), 2)

    _handle_movement(delta)
    _handle_rotation()

    # make the repeat rate longer if moving diagonally
    var adjusted_rate: float = DAS_RATE
    if input_dir.x != 0 and input_dir.y != 0:
        adjusted_rate *= 1.414

    # update move_dir if das repeat happens
    if das_repeat_count >= adjusted_rate:
        das_repeat_count = 0
        move_dir = input_dir

    piece_machine.active().position += move_dir
    if _is_piece_out_of_bounds():
        piece_machine.active().position -= move_dir

    # update @das_repeat_count
    if das_count >= DAS_DELAY:
        das_repeat_count += delta
    elif das_count == 0:
        das_repeat_count = DAS_RATE

    # draw the piece again
    _draw_piece(piece_machine.active(), 2)

    _handle_placement()


## Check if the active piece is currently out of bounds.
func _is_piece_out_of_bounds() -> bool:
    var piece: Piece = piece_machine.active()
    var outside: bool = false
    for i in range(piece.size):
        var cell_pos: Vector2i = piece.cells[i] + piece.position 
        if cell_pos.x < 0 or cell_pos.x > 9:
            outside = true
        if cell_pos.y < 0 or cell_pos.y > 9:
            outside = true
    return outside


## Check if the active piece is currently placeable.
func _is_piece_placeable() -> bool:
    var piece: Piece = piece_machine.active()
    for i in range(piece.size):
        var cell: Vector2i = piece.position + piece.cells[i]
        if current_roads.has(cell):
            return false
    return true


## Places the active piece in the permanent tile layer and gets a new active
## piece.
func _place_piece() -> void:
    _clear_piece(piece_machine.active(), 2)
    _draw_piece(piece_machine.active(), 1)
    _new_active_piece()


func _new_active_piece() -> void:
    piece_machine.new_piece()
    piece_machine.active().position = Vector2i(5, 5)
    
    
## Draw @piece to its cells on tilemap layer @layer
func _draw_piece(piece: Piece, layer: int) -> void:
    for i in range(piece.size):
        var road: Road = piece.roads[i]
        var cell: Vector2i = piece.position + piece.cells[i]
        set_cell(layer, cell, road.get_id(), road.get_atlas_coords())

        if layer == 1:
            current_roads[cell] = road


func _clear_piece(piece: Piece, layer: int):
    for i in range(piece.size):
        erase_cell(layer, piece.position + piece.cells[i])
