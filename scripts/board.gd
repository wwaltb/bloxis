class_name Board
extends TileMapLayer


## Draws @piece to the active layer.
func draw(piece: Piece) -> void:
    for i in range(piece.size):
        var tile: PieceTile = piece.tiles[i]
        var cell: Vector2i = piece.position + piece.cells[i]
        set_cell(cell, tile.get_id(), tile.get_atlas_coords())
