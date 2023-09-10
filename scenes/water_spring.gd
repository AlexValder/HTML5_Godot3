extends Node2D
class_name WaterSpring

signal splash

onready var collision := $area/shape as CollisionShape2D

var velocity := 0.0
var force := 0.0
var height := 0.0
var target_height := 0.0
var index := 0
var motion_factor := 0.015
var collided_with: Drop = null


func water_update(spring_constant: float, dampening: float) -> void:
    ## This function applies the hooke's law force to the spring!!
    ## This function will be called in each frame
    ## hooke's law ---> F =  - K * x

    height = position.y

    var x := height - target_height
    var loss := -dampening * velocity

    force = - spring_constant * x + loss
    velocity += force
    position.y += velocity


func initialize(x_position: float, id: int) -> void:
    height = position.y
    target_height = position.y
    velocity = 0
    position.x = x_position
    index = id


func set_collision_width(value: float) -> void:
    var extents := collision.shape.extents as Vector2
    var new_extents := Vector2(value/2, extents.y)
    collision.shape.extents = new_extents


func _on_area_body_entered(body: Drop) -> void:
    if body == null || body == collided_with:
        return

    body.in_water()
    collided_with = body
    var speed = body.linear_velocity.y * motion_factor

    emit_signal("splash", index, speed)
