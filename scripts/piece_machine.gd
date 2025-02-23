class_name PieceMachine
extends RefCounted

const NUM_BAGS: int = 1

# These keep track of the possible unique pieces. They are defined at the
# bottom of the file.
var singles: Array[Piece]
var couples: Array[Piece]
var throuples: Array[Piece]

var piece_stack: Array[Piece]  ## Stack of ready pieces. Use get_piece() to grab one.


## Create a piece machine with a set of pieces loaded into @piece_stack.
func _init() -> void:
    _initialize_pieces()
    _new_set()


## Get the active piece.
func active() -> Piece:
    if piece_stack.back() == null:
        _new_set()
    return piece_stack.back()


## Get the piece that will come @pieces from now.
func next_in(pieces: int) -> Piece:
    return piece_stack[piece_stack.size() - 1 - pieces]


## Pop the active piece from the stack
func new_piece() -> void:
    if piece_stack.pop_back() == null:
        _new_set()


## Fills piece_stack with a new randomized set of @NUM_BAGS bags
func _new_set() -> void:
    for i in range(NUM_BAGS):
        _generate_bag()
    piece_stack.shuffle()


## Generates each individual bag for the new set. Has the job of finding unique
## pieces when applicable.
func _generate_bag() -> void:
    piece_stack.append_array(throuples)
    piece_stack.append_array(couples)
    piece_stack.append_array(singles)
    piece_stack.append_array(singles)


## Create our game pieces (one-long up to three-long)
func _initialize_pieces() -> void:
    singles = [Piece.new([Compass.S], 0), Piece.new([Compass.W], 0)]
    couples = [
        Piece.new([Compass.S, Compass.S], 0),
        Piece.new([Compass.S, Compass.W], 1),
        Piece.new([Compass.S, Compass.E], 2),
        Piece.new([Compass.W, Compass.N], 3),
        Piece.new([Compass.W, Compass.S], 4),
        Piece.new([Compass.E, Compass.S], 0)
    ]
    throuples = [
        Piece.new([Compass.S, Compass.S, Compass.S], 0),
        Piece.new([Compass.S, Compass.S, Compass.W], 1),
        Piece.new([Compass.S, Compass.S, Compass.E], 2),
        Piece.new([Compass.S, Compass.W, Compass.S], 3),
        Piece.new([Compass.S, Compass.W, Compass.W], 4),
        Piece.new([Compass.S, Compass.W, Compass.N], 0),
        Piece.new([Compass.S, Compass.E, Compass.S], 1),
        Piece.new([Compass.S, Compass.E, Compass.N], 2),
        Piece.new([Compass.W, Compass.S, Compass.W], 3),
        Piece.new([Compass.W, Compass.S, Compass.E], 4),
        Piece.new([Compass.W, Compass.W, Compass.N], 0),
        Piece.new([Compass.W, Compass.W, Compass.S], 1),
        Piece.new([Compass.E, Compass.S, Compass.W], 2),
        Piece.new([Compass.E, Compass.E, Compass.S], 3)
    ]
