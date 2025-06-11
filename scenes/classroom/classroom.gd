class_name Classroom
extends Node2D


@export var desks_grid: Control
@export var scrap_amount: int

@export var position_offset_max: Vector2
var desks: Dictionary[Control, StudentDesk]
var aligment_indicators: Dictionary[Control, Control]

var level_beat: bool

@export var paper_scrap: PackedScene


@onready var timer: RichTextLabel = $Sprite2D/Timer

var start_time : float = 5 * 60
var time_elapsed : float = start_time
var minutes: float
var seconds: float
var milliseconds: float
var time_string: String
var rotation_speed: float


func  _ready() -> void:
	for control: Control in desks_grid.get_children():
		if control.get_child_count() != 2:
			push_warning("desk control node has wrong amonut of children")
		else:
			desks[control] = control.get_child(0) as Node2D
			aligment_indicators[control] = control.get_child(1) as Control
			desks[control].focused.connect(func () -> void: aligment_indicators[control].show())
			desks[control].unfocused.connect(func () -> void: aligment_indicators[control].hide())
	hide_indicators()
	scramble_desks()
	distribute_scrap()

func _process(delta: float) -> void:
	if level_beat:
		return
	time_elapsed -= delta
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	milliseconds = fmod(time_elapsed, 1) * 100
	time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	timer.text = "[color=#ffe7d6]%s[/color]" % [time_string]
	Game.rottaion_speed = remap(PaperScrap.score, 0, scrap_amount, 0.5, 0.01)
	for desk: StudentDesk in desks.values():
		if !desk.is_aligned():
			return
	if PaperScrap.score >= scrap_amount:
		level_beat = true
		game_finshed()


func game_finshed():
	Game.run_finished.emit(start_time - time_elapsed)

func hide_indicators() -> void:
	for inidicator: Control in aligment_indicators.values():
		inidicator.hide()

func scramble_desks() -> void:
	for student_desk: StudentDesk in desks.values():
		student_desk.position = rand_vec2(-position_offset_max, position_offset_max)
		student_desk.rotate_object(student_desk.desk, randf_range(0, 360))
		student_desk.rotate_object(student_desk.chair, randf_range(0, 360))

func distribute_scrap() -> void:
	for i in scrap_amount:
		var scrap: Node2D = paper_scrap.instantiate()
		scrap.global_position = rand_vec2(-Vector2(300, 400), Vector2(300, 400))
		add_child(scrap)

func rand_vec2(min_v: Vector2, max_v: Vector2) -> Vector2:
	return Vector2(randf_range(min_v.x, max_v.x), randf_range(min_v.y, max_v.y))
