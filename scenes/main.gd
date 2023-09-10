extends Control

onready var _water := $level/water as Water2D
onready var _audio_icon := $hbox2/icon as TextureButton
onready var _audio := $audio as AudioStreamPlayer
onready var _bus := AudioServer.get_bus_index("Master")

var _muted := false
var _index := 0
var _colors := [
    Color("#0a378f"),
    Color.blue,
    Color.aqua,
    Color.darkblue,
    Color.green,
    Color.crimson,
   ]
var _audios := [
    "res://assets/audio/angry animal.wav",
    "res://assets/audio/animal curious.wav",
    "res://assets/audio/animal friendly.wav",
    "res://assets/audio/animal timid.wav",
    "res://assets/audio/bird 1.wav",
    "res://assets/audio/bird 2.wav",
    "res://assets/audio/bird 3.wav",
    "res://assets/audio/bird 4.wav",
    "res://assets/audio/bird 5.wav",
    "res://assets/audio/happy bird.wav",
]
var _audio_on := load("res://assets/pics/speaker_on.png")
var _audio_off := load("res://assets/pics/speaker_off.png")


func spawn_drop(pos: Vector2) -> void:
    var scene := load("res://scenes/drop.tscn") as PackedScene
    var drop := scene.instance() as Drop
    drop.position = pos
    drop.z_index = 5
    add_child(drop)


func _gui_input(event: InputEvent) -> void:
    if event.is_action_released("spawn"):
        if event is InputEventMouse:
            var e := event as InputEventMouse
            spawn_drop(e.position)
        else:
            var pos := get_viewport().get_mouse_position()
            spawn_drop(pos)


func _say_text(text: String) -> void:
    if OS.has_feature("JavaScript"):
        JavaScript.eval("alert('%s');" % text)
    else:
        print(text)


func _on_change_color_button_up() -> void:
    _index += 1
    if _index >= _colors.size():
        _index = 0

    _water.set_color(_colors[_index])


func _on_play_sound_button_up() -> void:
    _audio.stream = load(_audios[randi() % _audios.size()])
    _audio.play()


func _on_audio_slider_value_changed(value: float) -> void:
    _muted = value == 0.0
    _load_icon()

    AudioServer.set_bus_mute(_bus, false)
    AudioServer.set_bus_volume_db(_bus, linear2db(value))


func _on_audio_icon_button_up() -> void:
    _muted = !_muted
    AudioServer.set_bus_mute(_bus, _muted)
    _load_icon()


func _load_icon() -> void:
    if _muted:
        _audio_icon.texture_normal = _audio_off
    else:
        _audio_icon.texture_normal = _audio_on
