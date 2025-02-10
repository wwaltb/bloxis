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


func is_out_of_bounds() -> bool:
    for i in range(size):
        var cell: Vector2i = position + cells[i]
        if cell.x < 0 or cell.x > GameBoard.MAX_X:
            return true
        if cell.y < 0 or cell.y > GameBoard.MAX_Y:
            return true
    return false


func is_placeable() -> bool:
    if self.is_out_of_bounds():
        return false
    for i in range(size):
        var cell: Vector2i = position + cells[i]
        if typeof(GameBoard.current_tiles[cell]) == TYPE_OBJECT:
            return false
    return true


## Initialize a new piece that connects the given directions starting from
## North.
func _init(dirs: Array[int]) -> void:
    size = dirs.size()
    _generate_piece(dirs)


## Generate the piece's roads and cells.
func _generate_piece(dirs: Array[int]) -> void:
    for i in range(dirs.size()):
        if i == 0:
            roads.append(Road.new(Compass.N, dirs[i]))
            cells.append(Vector2i.ZERO)
        else:
            roads.append(Road.new(Compass.get_rotate_180(dirs[i-1]), dirs[i]))
            cells.append(cells[i-1] + Compass.get_vector2i(dirs[i-1]))
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
