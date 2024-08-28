class_name Cube
extends RefCounted

var atlas_source: TileSetAtlasSource


func _init(source: TileSetAtlasSource) -> void:
    atlas_source = source
    print(_get_anim_duration(Vector2i(0,3)))


## Get the time to play the animation of tile at @atlas_coords.
func _get_anim_duration(atlas_coords: Vector2i) -> float:
    var total_duration: float = atlas_source.get_tile_animation_total_duration(atlas_coords) 
    return total_duration / atlas_source.get_tile_animation_speed(atlas_coords)
