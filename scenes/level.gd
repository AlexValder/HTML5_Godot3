extends Node2D


func _ready() -> void:
    var size := OS.window_size

    var res := load("res://scenes/water.tscn") as PackedScene
    var water := res.instance() as Water2D
    water.z_index = 10
    water.set_length(size.x)
    add_child(water)
    water.position.x = 0
    water.position.y = size.y / 2
