extends TileMap

# piece bags
# next piece
# hold piece
# handle input
# drawing pieces

func draw_piece(piece: Piece, layer: int) -> void:
    for i in range(piece.size):
        var road: Road = piece.roads[i]
        var cell: Vector2i = piece.cells[i]
        set_cell(layer, piece.position + cell, road.get_id(), road.get_atlas_coords())
        #if layer == 0:
            #tiles_in_use[piece.position + cell] = piece.roads[i]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    draw_piece(Piece.new(3), 1)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
