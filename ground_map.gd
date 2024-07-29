class_name GroundMap
extends TileMap

# piece bags
# next piece
# hold piece
# handle input
# drawing pieces
var randomizer: Randomizer = Randomizer.new()

## Draw @piece to its cells on tilemap layer @layer
func draw_piece(piece: Piece, layer: int) -> void:
    for i in range(piece.size):
        var road: Road = piece.roads[i]
        var cell: Vector2i = piece.cells[i]
        set_cell(layer, piece.position + cell, road.get_id(), road.get_atlas_coords())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #draw_piece(randomizer.get_piece(), 1)
    print()
    print("--Test Piece--")
    var test_piece: Piece = Piece.new(1)
    draw_piece(test_piece, 1)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
