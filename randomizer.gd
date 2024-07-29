class_name Randomizer
extends RefCounted

const NUM_BAGS: int = 2

var all_pieces: Array[Piece]
var piece_stack: Array[Piece]


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
    for i in range(4):
        if i < 2:
            piece_stack.append(Piece.new(3))
        elif i < 3:
            piece_stack.append(Piece.new(2))
        else:
            piece_stack.append(Piece.new(1))


func _initialize_pieces() -> void:
    pass
    

func _get_pieces_of_size(size) -> Array[Piece]:
    if size == 1:
        # can only be NS or NW
        var pieces: Array[Piece] = [Piece.new(), Piece.new()]
        pieces[0].roads[0].to = Compass.S
        pieces[1].roads[0].to = Compass.W
        return pieces
    else:
        return _get_possible_pieces(size, Piece.new())
    

func _get_possible_pieces(tiles_left: int, piece: Piece) -> Array[Piece]:
    var possible_pieces = Array[Piece]

    var prev_road: Road = piece.roads[piece.size-1]
    var next_road: Road = Road.new(prev_road)

    # add a tile to the piece. we will set its direction later
    piece.add_road(next_road)

    # base case
    if tiles_left == 1:
        var skip_dirs: Array[int] = [Compass.get_rotate_180(prev_road.to)]
        if piece.roads[0].to == Compass.S:
            
        pass

    # tiles can be completely random with a straight starting road
    if piece.roads[0].to == Compass.S:
        # add a tile that goes in each possible direction
        for i in range(Compass.NUM_DIRS):
            # skip the tile's starting direction
            if i == Compass.get_rotate_180(prev_road.to):
                continue
            piece.roads[piece.size-1].to = i
            possible_pieces.append_array(_get_possible_pieces(tiles_left-1, piece))

    # curved pieces cannot have a middle road going back North
    elif tiles_left == 1:
        for i in range(Compass.NUM_DIRS):
            # skip North and the tile's starting direction
            if i == Compass.N or i == Compass.get_rotate_180(prev_road.to):
                continue
            piece.roads[piece.size-1].to = i
            possible_pieces.append_array(_get_possible_pieces(tiles_left-1, piece))

        

func _init() -> void:
    _new_set()
