extends TileMap

const ROAD_ID = 11
const ROAD_ATLAS = {
    "NE": Vector2i(9, 0),
    "NS": Vector2i(6, 0),
    "NW": Vector2i(10, 0),
    "EN": Vector2i(9, 0),
    "ES": Vector2i(7, 0),
    "EW": Vector2i(8, 0),
    "SN": Vector2i(6, 0),
    "SE": Vector2i(7, 0),
    "SW": Vector2i(5, 0),
    "WN": Vector2i(10, 0),
    "WE": Vector2i(8, 0),
    "WS": Vector2i(5, 0)
}

const TRUCK_ID = 17
const TRUCK_ATLAS = {
    "NE": Vector2i(4, 0),
    "NS": Vector2i(1, 0),
    "NW": Vector2i(8, 0),
    "EN": Vector2i(5, 0),
    "ES": Vector2i(10, 0),
    "EW": Vector2i(3, 0),
    "SN": Vector2i(2, 0),
    "SE": Vector2i(11, 0),
    "SW": Vector2i(7, 0),
    "WN": Vector2i(9, 0),
    "WE": Vector2i(0, 0),
    "WS": Vector2i(6, 0)
}
const TRUCK_START = Vector2i(10, 19)
const TRUCK_GOAL = Vector2i(8, -1)
const TRUCK_END = Vector2i(-2, -6)
const TRUCK_DELAY = 20
const TRUCK_RATE = 1

const DAS_DELAY = 0.28
const DAS_RATE = 0.05

var next_piece: Piece
var active_piece: Piece

var das_count = 0;
var das_repeat_count = 0

var tiles_in_use = {}
var trucks = []
var new_truck_count = 0

var score = 0

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
    _new_next_piece()

    _clear_piece(next_piece, 3)
    next_piece.position -= Vector2i(1, 1)
    _clear_piece(next_piece, 2)

    _new_active_piece()
    _new_next_piece()

    _new_truck()

    get_node("GameOver").hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if game_over:
        return

    if Input.is_action_just_pressed("place"):
        _place_piece()

    if Input.is_action_just_pressed("rotate_right"):
        _clear_piece(active_piece, 1)
        _rotate_piece_right(active_piece)
        _center_piece(active_piece)
        _draw_piece(active_piece, 1)

    if Input.is_action_just_pressed("rotate_left"):
        _clear_piece(active_piece, 1)
        _rotate_piece_left(active_piece)
        _center_piece(active_piece)
        _draw_piece(active_piece, 1)

    var input_dir := Vector2i(0, 0)
    var move := Vector2i(0, 0)

    # set move if input is just pressed
    if Input.is_action_just_pressed("move_forward"):
        move.y += -1
        das_count = 0

    if Input.is_action_just_pressed("move_backward"):
        move.y += 1
        das_count = 0

    if Input.is_action_just_pressed("move_left"):
        move.x += -1
        das_count = 0

    if Input.is_action_just_pressed("move_right"):
        move.x += 1
        das_count = 0

    # set input dir if input is being held
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

    # start das movement when das is above delay
    if das_count >= DAS_DELAY:
        das_repeat_count -= delta

    if das_repeat_count <= 0:
        move = input_dir
        das_repeat_count = DAS_RATE

    # update based on move vector
    _clear_piece(active_piece, 1)
    _move_piece(active_piece, move)
    _draw_piece(active_piece, 1)

    new_truck_count += delta
    if new_truck_count >= TRUCK_DELAY:
        new_truck_count = 0
        _new_truck()

    _update_trucks(delta)

    get_node("Score").text = str(score)


# Returns a random road tile key
func _get_random_road() -> String:
    var keys = ROAD_ATLAS.keys()
    return keys[randi() % keys.size()]

func _get_opposite_dir(dir) -> String:
    match dir:
        "N":
            return "S"    
        "E":
            return "W"
        "S":
            return "N"
        "W":
            return "E"
        _:
            return "ERROR"

func _get_next_cell(cell, dir) -> Vector2i:
    match dir:
        "N":
            return Vector2i(cell.x, cell.y + 1)
        "E":
            return Vector2i(cell.x - 1, cell.y)
        "S":
            return Vector2i(cell.x, cell.y - 1)
        "W":
            return Vector2i(cell.x + 1, cell.y)
        _:
            return cell

func _generate_next_road(prev_road) -> String:
    var road = ""

    # next road needs to start with the opposite direction of what the
    # previous ended with
    while true:
        road = _get_random_road()
        if road[0] == _get_opposite_dir(prev_road[1]):
            break

    return road

func _generate_piece(tiles) -> Piece:
    var piece = Piece.new()
    var road = ""
    var cell = Vector2i(0, 0)

    for i in range(tiles):
        # generate first tile
        if road.is_empty():
            road = _get_random_road()
            piece.add_tile(road, cell)
            continue

        # track previously generated piece
        var prev_road = road
        var prev_cell = cell

        # generate next road and cell and make sure that this new tile does not
        # direct to an existing tile in the piece
        while true:
            road = _generate_next_road(prev_road)
            cell = _get_next_cell(prev_cell, prev_road[1])

            var collided = false
            for c in piece.cells:
                if _get_next_cell(cell, road[1]) == c:
                    collided = true
            if not collided:
                break

        piece.add_tile(road, cell)

    return piece

func _new_next_piece():
    var tiles: int
    var roll = randi() % 10
    if roll > 5:
        tiles = 3
    elif roll > 1:
        tiles = 2
    else:
        tiles = 1

    while true:
        next_piece = _generate_piece(tiles)
        if not _is_loop(next_piece):
            break
    _center_piece(next_piece)

    next_piece.position = Vector2i(-4, 4)
    _draw_piece(next_piece, 2)
    next_piece.position += Vector2i(1, 1)
    _draw_piece(next_piece, 3)

func _new_active_piece():
    active_piece = next_piece
    _center_piece(active_piece)

    active_piece.position = Vector2i(5, 5)
    _draw_piece(active_piece, 1)

func _center_piece(piece):
    if piece.tiles < 3:
        return

    var cell1 = piece.cells[1]
    var offset = Vector2i.ZERO - cell1

    for i in range(piece.tiles):
        piece.cells[i] += offset

func _is_loop(piece) -> bool:
    if piece.tiles < 3:
        return false

    var road0 = piece.roads[0]
    var cell0 = piece.cells[0]
    var road2 = piece.roads[2]
    var cell2 = piece.cells[2]

    if _get_next_cell(cell0, road0[0]) == _get_next_cell(cell2, road2[1]):
        print("LOOP!")
        return true
    else:
        return false

func _rotate_dir_right(dir) -> String:
    match dir:
        "N":
            return "E"    
        "E":
            return "S"
        "S":
            return "W"
        "W":
            return "N"
        _:
            return "ERROR"

func _rotate_dir_left(dir) -> String:
    match dir:
        "N":
            return "W"    
        "E":
            return "N"
        "S":
            return "E"
        "W":
            return "S"
        _:
            return "ERROR"

func _rotate_piece_right(piece):
    var cell = Vector2i(0, 0)
    for i in range(piece.tiles):
        var road = piece.roads[i]
        road[0] = _rotate_dir_right(road[0])
        road[1] = _rotate_dir_right(road[1])

        piece.roads[i] = road
        piece.cells[i] = cell

        cell = _get_next_cell(cell, road[1])

func _rotate_piece_left(piece):
    var cell = Vector2i(0, 0)
    for i in range(piece.tiles):
        var road = piece.roads[i]
        road[0] = _rotate_dir_left(road[0])
        road[1] = _rotate_dir_left(road[1])

        piece.roads[i] = road
        piece.cells[i] = cell

        cell = _get_next_cell(cell, road[1])

func _move_piece(piece, move_dir):
    var next_position = piece.position + move_dir

    for i in range(piece.tiles):
        var next_cell_position = next_position + piece.cells[i]

        if next_cell_position.x < 0 or next_cell_position.x > 10:
            return

        if next_cell_position.y < 0 or next_cell_position.y > 10:
            return

    piece.position = next_position

func _draw_piece(piece, layer):
    for i in range(piece.tiles):
        set_cell(layer, piece.position + piece.cells[i], ROAD_ID, ROAD_ATLAS[piece.roads[i]])
        if layer == 0:
            tiles_in_use[piece.position + piece.cells[i]] = piece.roads[i]

func _clear_piece(piece, layer):
    for i in range(piece.tiles):
        erase_cell(layer, piece.position + piece.cells[i])

func _place_piece():
    for i in range(active_piece.tiles):
        var cell = active_piece.cells[i] + active_piece.position
        if tiles_in_use.has(cell):
            return false

    _clear_piece(next_piece, 3)
    next_piece.position -= Vector2i(1, 1)
    _clear_piece(next_piece, 2)
    _clear_piece(active_piece, 1)
    _draw_piece(active_piece, 0)
    _new_active_piece()
    _new_next_piece()

    return true

# update trucks position and direction
# returns true on success, false if crash
func _move_truck(truck) -> bool:
    # start movement
    if truck.pos.y > 17:
        truck.pos.y -= 1
        return true

    if truck.pos.y == 17:
        truck.pos.y -= 1
        truck.dir = "NE"
        return true

    if truck.pos.y == 16 and truck.pos.x > 3:
        truck.pos.x -= 1
        truck.dir = "WE"
        return true

    if truck.pos.y == 16 and truck.pos.x == 3:
        truck.pos.x -= 1
        truck.dir = "WS"
        return true

    if truck.pos.y > 11:
        truck.pos.y -= 1
        truck.dir = "NS"
        return true

    # find next expected tile position
    var next_tile = _get_next_cell(truck.pos, truck.dir[1])

    # end movement
    if next_tile == TRUCK_GOAL:
        truck.prev1 = truck.prev0
        truck.prev0 = truck.pos
        truck.pos.y -= 1
        truck.dir = "NS"

        score += 1

        return true

    if truck.pos.y < -5:
        truck.pos.x -= 1
        truck.dir = "WE"
        return true
        
    if truck.pos.y == -5:
        truck.pos.y -= 1
        truck.dir = "NE"
        return true

    if truck.pos.y < 0:
        truck.prev1 = truck.prev0
        truck.prev0 = truck.pos
        truck.pos.y -= 1
        truck.dir = "NS"
        return true

    # game board movement

    # tile in correct spot
    if tiles_in_use.has(next_tile):
        print(tiles_in_use[next_tile])
        # tile connects based on trucks direction
        if tiles_in_use[next_tile].contains(_get_opposite_dir(truck.dir[1])):
            truck.prev1 = truck.prev0
            truck.prev0 = truck.pos
            truck.pos = next_tile
            var origin_idx = tiles_in_use[next_tile].find(_get_opposite_dir(truck.dir[1]))
            truck.dir[0] = tiles_in_use[next_tile][origin_idx]
            truck.dir[1] = tiles_in_use[next_tile][1 - origin_idx]
        # otherwise hit a wall
        else:
            return false
    # truck falls if no tile
    else:
        return false

    return true

func _new_truck():
    var truck = Truck.new()
    set_cell(4, truck.pos, TRUCK_ID, TRUCK_ATLAS[truck.dir])
    trucks.append(truck)

func _update_trucks(delta):
    for truck in trucks:
        truck.rate -= delta
        
        var crashed: bool = false
        if truck.rate <= 0:
            truck.rate = TRUCK_RATE
            erase_cell(4, truck.pos)
            crashed = not _move_truck(truck)
            if not crashed:
                set_cell(4, truck.pos, TRUCK_ID, TRUCK_ATLAS[truck.dir])
                print(truck.prev1)
                if truck.prev1.y < 11 and truck.prev1.y >= 0:
                    tiles_in_use.erase(truck.prev1)
                    erase_cell(0, truck.prev1)
            else:
                game_over = true
                get_node("GameOver").show()

class Piece:
    var tiles: int = 0
    var roads = []
    var cells = []

    var position = Vector2i(0, 0)

    func add_tile(road, cell):
        tiles += 1
        roads.append(road)
        cells.append(cell)

class Truck:
    var pos := TRUCK_START
    var dir: String = "NS"
    var rate = TRUCK_RATE
    var prev0 = Vector2i(-1, -1)
    var prev1 = Vector2i(-1, -1)
