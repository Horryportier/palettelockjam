class_name Classroom
extends Node2D


@export var desks_grid: Control
@export var scrap_amount: int

@export var position_offset_max: Vector2
@export var rotation_speed_curve: Curve
var desks: Dictionary[Control, StudentDesk]
var aligment_indicators: Dictionary[Control, Control]

var level_beat: bool

@export var paper_scrap: PackedScene

@onready var timer: RichTextLabel = %BoardTimer
@onready var teacher: CharacterBody2D = %Teacher
@onready var teacher_desk: Control = %TeacherDeskSet

@onready var story: DialogueResource =   preload("uid://bsvh3qcu5w77o")

var start_time : float = 5 * 60
var time_elapsed : float = start_time
var minutes: float
var seconds: float
var milliseconds: float
var time_string: String
var rotation_speed: float

var level_started: bool

func  _ready() -> void:
	await Game.start_game
	timer.hide()
	Game._start_run.connect(start_level)
	desks[teacher_desk] = teacher_desk.get_child(0) as Node2D
	aligment_indicators[teacher_desk] = teacher_desk.get_child(1)
	desks[teacher_desk].focused.connect(func () -> void: aligment_indicators[teacher_desk].show())
	desks[teacher_desk].unfocused.connect(func () -> void: aligment_indicators[teacher_desk].hide())
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
	DialogueManager.show_dialogue_balloon(story, "start", [self])

func _process(delta: float) -> void:
	if !level_started: 
		return
	if level_beat:
		return
	time_elapsed -= delta
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	milliseconds = fmod(time_elapsed, 1) * 100
	time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	timer.text = "[color=#ffe7d6]%s[/color]" % [time_string]
	Game.rottaion_speed = rotation_speed_curve.sample(remap(PaperScrap.score, 0, scrap_amount, 1, 0))
	if time_elapsed <= 0: 
		game_finshed(false)
	for desk: StudentDesk in desks.values():
		if !desk.is_aligned():
			return
	if PaperScrap.score >= scrap_amount:
		level_beat = true
		game_finshed(false)

func start_level() -> void:
	DialogueManager.dialogue_ended.emit()
	timer.show()
	level_started = true

func show_teacher() -> void:
	teacher.show()

func set_time_limit(time: float):
	start_time = time * 60 

func game_finshed(abounded: bool) -> void:
	var state: Game.FailureState  = Game.FailureState.None
	if !level_beat: 
		state = Game.FailureState.RunnedOutOfTime
	if abounded:
		state = Game.FailureState.AbandonedRun
	Game.run_finished.emit(start_time - time_elapsed, state)

func abandoned_run() -> void:
	game_finshed(true)
	
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
