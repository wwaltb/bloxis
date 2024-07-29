class_name Piece
extends RefCounted

var size: int = 0

var roads: Array[Road]      ## The list of roads in the piece
var cells: Array[Vector2i]  ## The list of cells the piece occupies at the origin

var position = Vector2i(0, 0)


## Add @offset to the piece's position.
func move_piece(offset: Vector2i):
    position += offset


## Rotates the piece to the right
func rotate_right() -> void:
    # replace @to and @from of each @road with its rotated value and rebuild @cells
    cells.clear()
    for i in range(size):
        roads[i].to = Compass.get_rotate_90(roads[i].to)
        roads[i].from = Compass.get_rotate_90(roads[i].from)
        # rebuilding cells:
        if i == 0:
            cells.append(Vector2i.ZERO) # start from origin
        else:
            cells.append(cells[i-1] + Compass.get_vector2i(roads[i-1].to))  # the cell that the previous road points to
    # make sure piece is centered afterwards
    _center_piece()


## Rotates the piece to the left
func rotate_left() -> void:
    # replace @to and @from of each @road with its rotated value and rebuild @cells
    cells.clear()
    for i in range(size):
        roads[i].to = Compass.get_rotate_270(roads[i].to)
        roads[i].from = Compass.get_rotate_270(roads[i].from)
        # rebuilding cells:
        if i == 0:
            cells.append(Vector2i.ZERO) # start from origin
        else:
            cells.append(cells[i-1] + Compass.get_vector2i(roads[i-1].to))  # the cell that the previous road points to
    # make sure piece is centered afterwards
    _center_piece()


func add_road(road: Road) -> void:
    roads.append(road)
    cells.append(cells[size] + Compass.get_vector2i(Compass.get_rotate_180(road.from)))
    size += 1


## Initialize a new piece with @n roads which starts from the North.
func _init(n: int = 1) -> void:
    size = n
    _generate_piece()


## Generate the piece's roads and cells.
func _generate_piece() -> void:
    print()
    print("New piece:")
    # generate piece-wide @from and @to
    var from: int = Compass.N
    var to: int = Compass.get_random()
    if size == 1:
        to = Compass.get_random_other_than(from)
    print("  from: ", from, " to: ", to)
    # fill in roads to match @from and @to
    for i in range(size, 0, -1):
        var road: Road
        var cell: Vector2i
        # first road comes from @from
        if i == size:
            road = Road.new()
            road.from = from
            cell = Vector2i.ZERO
        # subsequent roads connect to prev still
        else:
            var prev_idx: int = size - (i+1)
            road = Road.new(roads[prev_idx])
            cell = cells[prev_idx] + Compass.get_vector2i(roads[prev_idx].to)
        # road can go any direction if more than two left
        if i > 2:
            road.to = Compass.get_random_other_than(road.from)
        # second to last piece needs to set up the last
        elif i > 1:
            road.to = Compass.get_random_other_than(Compass.get_rotate_180(to))
            # keep generating if we get the same direction as @road.from
            while road.to == road.from:
                road.to = Compass.get_random_other_than(Compass.get_rotate_180(to))
        # last piece goes towards @to
        else:
            road.to = to
        # append road and cell to their arrays
        roads.append(road)
        cells.append(cell)
        print(" road #", size-i+1)
        print("   from: ", road.from, " to: ", road.to)
    #for i in range(size):
    #    if i == 0:
    #        roads.append(Road.new())    # random first road
    #        cells.append(Vector2i.ZERO) # start from origin
    #    else:
    #        roads.append(Road.new(roads[i-1]))                              # random road connecting to the previous
    #        cells.append(cells[i-1] + Compass.get_vector2i(roads[i-1].to))  # the cell that the previous road points to
    # center piece around it's middle/end
    _center_piece()


## Standardize generated pieces so that they spawn the same way even when
## generated in different orientations
func _standardize_piece() -> void:
    pass


## Center @cells around the second road, as this is either the ## middle or end
## of a piece. Needs to be called after any function which otherwise changes
## @cells.
func _center_piece():
    # cannot center single length pieces
    if size < 2:
        return
    # set anchor and get the offset needed to ZERO that cell
    var anchor: Vector2i = cells[1]
    var offset: Vector2i = Vector2i.ZERO - anchor
    # add offset to each cell
    for i in range(size):
        cells[i] += offset
