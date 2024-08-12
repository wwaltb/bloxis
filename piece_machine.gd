class_name PieceMachine
extends RefCounted

const NUM_BAGS: int = 2

# These keep track of the possible unique pieces. They are defined at the
# bottom of the file.
var singles: Array[Piece]
var couples: Array[Piece]
var throuples: Array[Piece]

var piece_stack: Array[Piece] ## Stack of ready pieces. Use get_piece() to grab one.


## Create a piece machine with a set of pieces loaded into @piece_stack.
func _init() -> void:
    _initialize_pieces()
    _new_set()


## The method to get the next random piece from the randomizer.
func get_piece() -> Piece:
    var next_piece: Piece = piece_stack.pop_back()
    if not next_piece:
        _new_set()
        next_piece = piece_stack.pop_back()
        pass
    return next_piece


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
    singles = [
        Piece.new([Compass.S]),
        Piece.new([Compass.W])
    ]
    couples = [
        Piece.new([Compass.S, Compass.S]),
        Piece.new([Compass.S, Compass.W]),
        Piece.new([Compass.S, Compass.E]),
        Piece.new([Compass.W, Compass.N]),
        Piece.new([Compass.W, Compass.S]),
        Piece.new([Compass.E, Compass.S])
    ]
    throuples = [
        Piece.new([Compass.S, Compass.S, Compass.S]),
        Piece.new([Compass.S, Compass.S, Compass.W]),
        Piece.new([Compass.S, Compass.S, Compass.E]),
        Piece.new([Compass.S, Compass.W, Compass.S]),
        Piece.new([Compass.S, Compass.W, Compass.W]),
        Piece.new([Compass.S, Compass.W, Compass.N]),
        Piece.new([Compass.S, Compass.E, Compass.S]),
        Piece.new([Compass.S, Compass.E, Compass.N]),
        Piece.new([Compass.W, Compass.S, Compass.W]),
        Piece.new([Compass.W, Compass.S, Compass.E]),
        Piece.new([Compass.W, Compass.W, Compass.N]),
        Piece.new([Compass.W, Compass.W, Compass.S]),
        Piece.new([Compass.E, Compass.S, Compass.W]),
        Piece.new([Compass.E, Compass.E, Compass.S])
    ]
