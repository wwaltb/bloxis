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

## Initialize a new piece with @n roads
func _init(n: int) -> void:
    size = n
    _generate_piece()

## Generate the piece's roads and cells
func _generate_piece() -> void:
    for i in range(size):
        if i == 0:
            roads.append(Road.new())    # random first road
            cells.append(Vector2i.ZERO) # start from origin
        else:
            roads.append(Road.new(roads[i-1]))                              # random road connecting to the previous
            cells.append(cells[i-1] + Compass.get_vector2i(roads[i-1].to))  # the cell that the previous road points to
    # center piece around it's middle/end
    _center_piece()

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
