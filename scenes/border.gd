extends Path2D
class_name SmoothPath

export var spline_length := 8.0
export(bool) var _smooth setget smooth
export(bool) var _straighten setget straighten
export(Color) var color := Color(1,1,1,1)
var width := 8.0


func straighten(value: float) -> void:
    if not value:
        return

    for i in range(curve.get_point_count()):
        curve.set_point_in(i, Vector2())
        curve.set_point_out(i, Vector2())


func smooth(value: float) -> void:
    if not value:
        return

    var point_count := curve.get_point_count()
    for i in point_count:
        if i > 0 and i < point_count - 1:
            var spline = _get_spline(i)
            curve.set_point_in(i, -spline)
            curve.set_point_out(i, spline)


func _get_spline(i: int) -> Vector2:
    var last_point = _get_point(i - 1)
    var next_point = _get_point(i + 1)
    var spline = last_point.direction_to(next_point) * spline_length
    return spline


func _get_point(i: int) -> Vector2:
    var point_count = curve.get_point_count()
    i = wrapi(i, 0, point_count )
    if i > 1 and i < point_count-1:
        return curve.get_point_position(i)
    elif i <= 1:
        return Vector2(curve.get_point_position(1).x - spline_length,curve.get_point_position(1).y)
    elif i >= point_count - 1:
        return Vector2(curve.get_point_position(point_count-1).x + spline_length,curve.get_point_position(point_count-1).y)
    return Vector2.ZERO


func _draw() -> void:
    var points = curve.get_baked_points()
    if points:
        draw_polyline(points, color, width, true)
