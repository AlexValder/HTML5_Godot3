extends Node2D
class_name Water2D

export var k := 0.015
export var d := 0.03
export var spread := 0.2
export var distance_between_springs := 32
export var spring_number := 6
export var border_thickness := 1.1
export var depth := 1000

onready var water_polygon := $body as Polygon2D
onready var water_border := $border as SmoothPath
onready var shape := $area/shape as CollisionShape2D
onready var water_body_area := $area as Area2D

onready var water_spring := preload("res://scenes/water_spring.tscn")
onready var target_height := global_position.y
onready var bottom := target_height + depth

var springs := []
var passes := 12


func set_color(color: Color) -> void:
    var mat := water_polygon.material as ShaderMaterial
    mat.set_shader_param("color", color)


func set_length(length: float) -> void:
    spring_number = int(length / distance_between_springs) + 1


func _ready() -> void:
    water_border.width = border_thickness
    spread /= 1000

    for i in range(spring_number):
        var x_position := distance_between_springs * i
        var w := water_spring.instance()
        add_child(w)
        springs.append(w)
        w.initialize(x_position, i)
        w.set_collision_width(distance_between_springs)
        assert(w.connect("splash", self, "splash") == OK)

    var total_lenght := distance_between_springs * (spring_number - 1)
    var rectangle := RectangleShape2D.new().duplicate()

    var rect_position := Vector2(total_lenght / 2.0, depth / 2.0)
    var rect_extents := Vector2(total_lenght / 2.0, depth / 2.0)

    water_body_area.position = rect_position
    rectangle.set_extents(rect_extents)
    shape.set_shape(rectangle)


func _physics_process(_delta: float) -> void:
    for i in springs:
        i.water_update(k,d)

    var left_deltas := []
    var right_deltas := []

    for _i in range (springs.size()):
        left_deltas.append(0)
        right_deltas.append(0)

    for _j in range(passes):
        for i in range(springs.size()):
            if i > 0:
                left_deltas[i] = spread * (springs[i].height - springs[i - 1].height)
                springs[i - 1].velocity += left_deltas[i]
            if i < springs.size() - 1:
                right_deltas[i] = spread * (springs[i].height - springs[i + 1].height)
                springs[i + 1].velocity += right_deltas[i]

    new_border()
    draw_water_body()


func draw_water_body() -> void:
    var curve := water_border.curve
    var points := Array(curve.get_baked_points())
    var water_polygon_points := points
    var first_index := 0
    var last_index := water_polygon_points.size()-1

    water_polygon_points.append(Vector2(water_polygon_points[last_index].x, bottom))
    water_polygon_points.append(Vector2(water_polygon_points[first_index].x, bottom))

    water_polygon_points = PoolVector2Array(water_polygon_points)

    water_polygon.set_polygon(water_polygon_points)
    water_polygon.set_uv(water_polygon_points)


func new_border() -> void:
    var curve := Curve2D.new().duplicate()
    var surface_points := []
    for i in range(springs.size()):
        surface_points.append(springs[i].position)

    for i in range(surface_points.size()):
        curve.add_point(surface_points[i])

    water_border.curve = curve
    water_border.smooth(true)
    water_border.update()


func splash(index: int, speed: float) -> void:
    if index >= 0 and index < springs.size():
        springs[index].velocity += speed
