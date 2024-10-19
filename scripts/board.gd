class_name Board
extends TileMapLayer


## Draws @piece to the active layer.
func draw(piece: Piece) -> void:
    for i in range(piece.size):
        var road: Road = piece.roads[i]
        var cell: Vector2i = piece.position + piece.cells[i]
        set_cell(cell, road.get_id(), road.get_atlas_coords())
