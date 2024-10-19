extends AnimatedSprite2D
class_name SpawnTile

signal spawn_cube

var spawn_delay: float

var anim_queue: Array
var anim_duration: float


func _ready() -> void:
    play("none")
    _spawn_tile()


func _process(delta: float) -> void:
    if anim_duration <= 0 and anim_duration > -PI:
        if typeof(anim_queue.back()) == TYPE_CALLABLE:
            anim_queue.pop_back().call()                # [pop the corresponding callable]

        if typeof(anim_queue.back()) == TYPE_FLOAT:
            anim_duration = anim_queue.pop_back()       # [pop the new duration]
        else:
            anim_duration = _get_animation_duration(anim_queue.back())

        play(anim_queue.pop_back())                     # pop the old animation string
            
    anim_duration -= delta


func _get_animation_duration(anim: StringName) -> float:
    var frames: int = sprite_frames.get_frame_count(anim)
    var fps: float = sprite_frames.get_animation_speed(anim)

    var relative_duration: float = 0.0
    for i in range(frames):
        relative_duration += sprite_frames.get_frame_duration(anim, i)

    return relative_duration / (fps * speed_scale)


func _spawn_tile() -> void:
    # spawn the tile
    anim_queue.push_front("spawning")
    # idle for @spawn_delay seconds and then spawn a cube
    anim_queue.push_front(spawn_delay)
    anim_queue.push_front("idle")
    anim_queue.push_front(self._spawn_cube)
    

func _spawn_cube() -> void:
    spawn_cube.emit()
    anim_queue.push_front(-PI)     # Run state forever value
    anim_queue.push_front("idle")
    anim_queue.push_front(self._despawn_tile)


func _despawn_tile() -> void:
    anim_queue.push_front(-PI)
    anim_queue.push_front("despawning")
    anim_queue.push_front(self.queue_free)
    anim_queue.push_front("none")
