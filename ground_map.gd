class_name GroundMap
extends TileMap

# next piece
# hold piece
# handle input
# drawing pieces

const DAS_DELAY = 0.28
const DAS_RATE = 0.05

var das_count = 0;
var das_repeat_count = DAS_RATE
var move_dir: Vector2i = Vector2i.ZERO
var input_dir: Vector2i = Vector2i.ZERO

var next_piece: Piece
var active_piece: Piece

var piece_machine: PieceMachine = PieceMachine.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    active_piece = piece_machine.get_piece()
    _draw_piece(active_piece, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    _handle_movement(delta)
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
        

func _update_active_piece(delta: float) -> void:
    _clear_piece(active_piece, 1)

    # make the repeat rate longer if moving diagonally
    var adjusted_rate: float = DAS_RATE
    if input_dir.x != 0 and input_dir.y != 0:
        print("moving diagonally")
        adjusted_rate *= 1.414
    else:
        print("not")

    # update move_dir if das repeat happens
    if das_repeat_count >= adjusted_rate:
        das_repeat_count = 0
        move_dir = input_dir

    # update position based on move_dir (zero vector unless moving)
    var new_position = active_piece.position + move_dir
    # get new rotation
    # check if in bounds
    active_piece.position = new_position

    # update @das_repeat_count
    if das_count >= DAS_DELAY:
        das_repeat_count += delta
    elif das_count == 0:
        das_repeat_count = DAS_RATE

    # draw the piece again
    _draw_piece(active_piece, 1)
    
    
## Draw @piece to its cells on tilemap layer @layer
func _draw_piece(piece: Piece, layer: int) -> void:
    for i in range(piece.size):
        var road: Road = piece.roads[i]
        var cell: Vector2i = piece.cells[i]
        set_cell(layer, piece.position + cell, road.get_id(), road.get_atlas_coords())


func _clear_piece(piece: Piece, layer: int):
    for i in range(piece.size):
        erase_cell(layer, piece.position + piece.cells[i])
