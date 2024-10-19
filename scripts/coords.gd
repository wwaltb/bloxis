extends Node
## Translates grid coordinates to transform and vice versa


func to_transform(grid_coords: Vector2i) -> Vector2:
    var transform_coords: Vector2 = Vector2(24, 12)      # grid origin

    # translate horizontally
    if grid_coords.x > 0:
        transform_coords += grid_coords.x * Vector2(24, 12)
    else:
        transform_coords -= grid_coords.x * Vector2(-24, -12)
    # translate vertically
    if grid_coords.y > 0:
        transform_coords += grid_coords.y * Vector2(-24, 12)
    else:
        transform_coords -= grid_coords.y * Vector2(24, -12)

    return transform_coords
