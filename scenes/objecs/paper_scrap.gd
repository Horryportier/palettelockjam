class_name PaperScrap 
extends RigidBody2D

static var score: int

var is_hover: bool

var is_in_range: bool

func _ready() -> void:
	mouse_entered.connect(func () -> void: is_hover = true)
	mouse_exited.connect(func () -> void: is_hover = false)

func _physics_process(_delta: float) -> void:
	if is_in_range and Input.is_action_just_pressed("collect") and is_hover :
		score += 1
		queue_free()
