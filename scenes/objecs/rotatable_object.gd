class_name RotatableObject
extends StaticBody2D

@export var visual: Sprite2D
@export var collision_shape: CollisionShape2D
@export var sprite_angle_icrements: float

var current_angle: float

func rotate_object(angle: float) -> void:
	var snap_rotation: = angle_to_sprite_frame(angle, sprite_angle_icrements) * sprite_angle_icrements
	collision_shape.rotation = deg_to_rad(snap_rotation)
	current_angle = snap_rotation
	visual.frame = angle_to_sprite_frame(angle, sprite_angle_icrements)

func angle_to_sprite_frame(angle: float, increment: float) -> int:
	var a: = angle
	if angle >= 360:
		a = 0
	return int(a / increment)
	
