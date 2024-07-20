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

const NUM_TILES = 3

# Called when the node enters the scene tree for the first time.
func _ready():
    var piece = _generate_piece()
    print(piece)
    _draw_piece(piece, Vector2i(5, 5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

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

func _generate_piece() -> Piece:
    var piece = Piece.new()
    var road = ""
    var cell = Vector2i(0, 0)

    for i in range(NUM_TILES):
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
        print(i)
        while true:
            road = _generate_next_road(prev_road)
            cell = _get_next_cell(prev_cell, prev_road[1])

            var collided = false
            for c in piece.cells:
                print(c)
                if _get_next_cell(cell, road[1]) == c:
                    collided = true
            if not collided:
                break


        piece.add_tile(road, cell)

    return piece

func _draw_piece(piece, pos):
    for i in range(NUM_TILES):
        set_cell(0, pos + piece.cells[i], ROAD_ID, ROAD_ATLAS[piece.roads[i]])


class Piece:
    var roads = []
    var cells = []

    func _init():
        pass

    func add_tile(road, cell):
        roads.append(road)
        cells.append(cell)
