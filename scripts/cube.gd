class_name Cube
extends TileMapLayer

const CUBE_SOURCE: int = 0

## Enum to keep track of the states of the cube. Follows the order of the
## animations on the spritesheet and the first four (the moving animations)
## follow the compass directions enum as well.
enum States {
    MOVING_BACKWARD,
    MOVING_LEFT,
    MOVING_FORWARD,
    MOVING_RIGHT,
    SPAWNING,
    DONE,
    DYING,
    IDLE
}

var atlas_source: TileSetAtlasSource = tile_set.get_source(CUBE_SOURCE)

var tile_pos: Vector2i

var start_tile: Vector2i = Vector2i(0,10)
var end_tile: Vector2i = Vector2i(9,-1)

var state_times: Dictionary = {
    States.IDLE: 2.    
}

var state_queue: Array[States]
var current_state: States = States.SPAWNING
var current_state_time: float = 0


func _ready() -> void:
    _update_state_times()
    tile_pos = start_tile
    set_cell(tile_pos, CUBE_SOURCE, Vector2i(0, current_state))


func _process(delta: float) -> void:
    current_state_time += delta
    # start next state if time is up
    if current_state_time >= state_times[current_state]:
        current_state_time = 0
        if state_queue.is_empty():
            # HACK death
            if current_state == States.DYING:
                queue_free()
                return
            _update_state_queue()
        current_state = state_queue.pop_back()
        _enter_current_state()
    # update tile map:
    clear()
    set_cell(tile_pos, CUBE_SOURCE, Vector2i(0, current_state))


## Get the time to play the animation of tile at @atlas_coords.
func _get_anim_duration(atlas_coords: Vector2i) -> float:
    var total_duration: float = atlas_source.get_tile_animation_total_duration(atlas_coords) 
    return total_duration / atlas_source.get_tile_animation_speed(atlas_coords)


func _update_state_times() -> void:
    # all states other than IDLE
    for i in range(States.IDLE):
        state_times[i] = _get_anim_duration(Vector2i(0, i))


## Pushes next states to the queue. Never pushes IDLE last.
func _update_state_queue() -> void:
    # state is a moving state and corresponds to the dirs in @Compass
    if current_state >= States.MOVING_FORWARD and current_state <= States.MOVING_RIGHT:
        # check if tile is end
        if tile_pos == end_tile:
            state_queue.push_front(States.IDLE)
            state_queue.push_front(States.DONE)
            return
        # check if no tile
        if not GameBoard.current_tiles.has(tile_pos):
            state_queue.push_front(States.DYING)
            return

        var dest_tile: Road = GameBoard.current_tiles[tile_pos]
        # check if tile is blank
        if dest_tile.to == Compass.get_rotate_180(dest_tile.from):
            state_queue.push_front(States.IDLE)
            state_queue.push_front(current_state)
            return
        # move according to tiles direction
        state_queue.push_front(States.IDLE)
        state_queue.push_front(dest_tile.to)
        return

    # cube is spawning, so it will either move forward or left
    if current_state == States.SPAWNING:
        state_queue.push_front(States.IDLE)
        if start_tile.x > GameBoard.MAX_X:
            state_queue.push_front(States.MOVING_LEFT)
        else:
            state_queue.push_front(States.MOVING_FORWARD)
        return


## Handles the special logic for each state
func _enter_current_state() -> void:
    if current_state <= States.MOVING_RIGHT:
        tile_pos += Compass.get_vector2i(current_state)
