extends RigidBody2D
class_name Drop

onready var _sprite := $sprite as Sprite
onready var _audio_player := $audio as AudioStreamPlayer2D
onready var _size := OS.window_size.y

var _tracks := [
    "res://assets/audio/blop0.mp3",
    "res://assets/audio/blop1.mp3",
    "res://assets/audio/blop2.mp3",
]


func _ready() -> void:
    randomize()

    var tex := _sprite.texture as AtlasTexture
    tex.region.position.x = (randi() % 5) * 16
    tex.region.position.y = (randi() % 6) * 16


func _physics_process(_delta: float) -> void:
    if global_position.y >= _size:
        queue_free()


func in_water() -> void:
    _audio_player.stream = load(_tracks[randi() % 3])
    _audio_player.pitch_scale = (randf() + 0.5) / 2
    _audio_player.play()
    apply_central_impulse(-linear_velocity / 2)
