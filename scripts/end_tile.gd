class_name EndTile
extends AnimatedSprite2D

## queue (front -> back) of animation states in the form:
## duration: float [optional]
## name: StringName
## exit_function: Callable [optional]
var anim_queue: Array
var anim_duration: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    play("none")
    _spawn_tile()


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
    anim_queue.push_front("spawning")
    anim_queue.push_front(-PI)
    anim_queue.push_front("idle")
    anim_queue.push_front(self._despawn_tile)


func _despawn_tile() -> void:
    anim_queue.push_front("despawning")
    anim_queue.push_front(self._free)


func _free() -> void:
    queue_free()
    anim_queue.push_front("none")
