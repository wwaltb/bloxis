class_name Piece
extends RefCounted

var size: int = 0

var tiles: Array[PieceTile] ## The list of tiles in the piece
var cells: Array[Vector2i]  ## The list of cells the piece occupies at the origin

var position = Vector2i(0, 0)

var color = 0


## Add @offset to the piece's position.
func move_piece(offset: Vector2i):
    position += offset


## Rotates the piece to the right
func rotate_right() -> void:
    # replace @to and @from of each @tile with its rotated value and rebuild @cells
    cells.clear()
    for i in range(size):
        tiles[i].to = Compass.get_rotate_90(tiles[i].to)
        tiles[i].from = Compass.get_rotate_90(tiles[i].from)
        # rebuilding cells:
        if i == 0:
            cells.append(Vector2i.ZERO) # start from origin
        else:
            cells.append(cells[i-1] + Compass.get_vector2i(tiles[i-1].to))  # the cell that the previous tile points to
    # make sure piece is centered afterwards
    _center_piece()


## Rotates the piece to the left
func rotate_left() -> void:
    # replace @to and @from of each @tile with its rotated value and rebuild @cells
    cells.clear()
    for i in range(size):
        tiles[i].to = Compass.get_rotate_270(tiles[i].to)
        tiles[i].from = Compass.get_rotate_270(tiles[i].from)
        # rebuilding cells:
        if i == 0:
            cells.append(Vector2i.ZERO) # start from origin
        else:
            cells.append(cells[i-1] + Compass.get_vector2i(tiles[i-1].to))  # the cell that the previous tile points to
    # make sure piece is centered afterwards
    _center_piece()


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
func _init(dirs: Array[int], c: int) -> void:
    size = dirs.size()
    color = c
    _generate_piece(dirs)


## Generate the piece's tiles and cells.
func _generate_piece(dirs: Array[int]) -> void:
    for i in range(dirs.size()):
        if i == 0:
            tiles.append(PieceTile.new(Compass.N, dirs[i], color))
            cells.append(Vector2i.ZERO)
        else:
            tiles.append(PieceTile.new(Compass.get_rotate_180(dirs[i-1]), dirs[i], color))
            cells.append(cells[i-1] + Compass.get_vector2i(dirs[i-1]))
    _center_piece()


## Standardize generated pieces so that they spawn the same way even when
## generated in different orientations
func _standardize_piece() -> void:
    pass


## Center @cells around the second tile, as this is either the ## middle or end
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
