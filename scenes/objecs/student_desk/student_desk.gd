class_name  StudentDesk
extends Node2D

signal focused
signal unfocused

@export var max_player_distance: float
@export var snap_distance: float

@onready var desk: RotatableObject = $Desk
@onready var chair: RotatableObject = $Chair

enum Focus {
	None,
	Desk,
	Chair,
}

var focus: Focus:
	set(val):
		if val == Focus.None:
			unfocused.emit()
		else: 
			focused.emit()
		focus = val

var can_rotate: bool = true

var lock_position: bool
var lock_rotattion_desk: bool
var lock_rotattion_chair: bool

var player: Node2D

var delay_rotate: = func () -> void: get_tree().create_timer(Game.rottaion_speed).timeout.connect(func () -> void: can_rotate = true)

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	desk.mouse_exited.connect(func () -> void: focus = Focus.None)
	desk.mouse_entered.connect(func () -> void: focus = Focus.Desk)
	chair.mouse_exited.connect(func () -> void: focus = Focus.None)
	chair.mouse_entered.connect(func () -> void: focus = Focus.Chair)

func _process(_delta: float) -> void:
	if is_aligned():
		return
	if global_position.distance_to(player.global_position) > max_player_distance:
		return
	if desk.current_angle == 0:
		lock_rotattion_desk = true
	if chair.current_angle == 0:
		lock_rotattion_chair = true
	if Input.is_action_pressed("move") and (focus == Focus.Desk or focus == Focus.Chair) and !lock_position:
		global_position = get_global_mouse_position()
		if position.distance_to(Vector2.ZERO) <= snap_distance:
			position = Vector2.ZERO 
			print("locking position")
			lock_position = true
	if !lock_rotattion_desk:
		if Input.is_action_pressed("rotate_left") and focus == Focus.Desk and can_rotate:
			desk.rotate_object(desk.current_angle + 15)
			can_rotate = false
			delay_rotate.call()
		if Input.is_action_pressed("rotate_right") and focus == Focus.Desk and can_rotate:
			if desk.current_angle <= 0:
				desk.current_angle = 360
			desk.rotate_object(desk.current_angle - 15)
			can_rotate = false
			delay_rotate.call()
	if !lock_rotattion_chair:
		if Input.is_action_pressed("rotate_left") and focus == Focus.Chair and can_rotate:
			chair.rotate_object(chair.current_angle + 15)
			can_rotate = false
			delay_rotate.call()
		if Input.is_action_pressed("rotate_right") and focus == Focus.Chair and can_rotate:
			if chair.current_angle <= 0:
				chair.current_angle = 360
			chair.rotate_object(chair.current_angle - 15)
			can_rotate = false
			delay_rotate.call()


func rotate_object(object:  RotatableObject, angle: float):
	object.rotate_object(angle)

func is_aligned() -> bool:
	return  lock_position and lock_rotattion_chair and lock_rotattion_desk

