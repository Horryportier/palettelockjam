extends CharacterBody2D

@export var speed: float
@export var push_force: float
@onready var visual: CanvasGroup = $Visual
@onready var radar: Radar2D = $Radar2D

var state: StateDelegate

var facing_direction: Vector2
var last_non_zero_velocity: Vector2

var sprites: Array[AnimatedSprite2D]


func _ready() -> void:
	radar.body_tracked.connect(func (body: Node2D) -> void: body.is_in_range = true)
	radar.body_untracked.connect(func (body: Node2D) -> void: body.is_in_range = false)
	state = StateDelegate.new()
	state.add_state(_idle_state, "idle", _idle_enter_state)
	state.add_state(_walk_state, "walk", _walk_enter_state)
	state.add_state(_talk_state, "talk", _talk_enter_state)
	state.set_default_state(_idle_state)
	sprites.assign(visual.get_children().filter(func (x: Node) -> bool: return x is AnimatedSprite2D))
	DialogueManager.dialogue_started.connect(func (_resource: DialogueResource) -> void: state.set_state(_talk_state))
	DialogueManager.dialogue_ended.connect(func (_resource: DialogueResource) -> void: state.set_state(_idle_state))

func _process(delta: float) -> void:
	if state.is_state(_talk_state):
		state.tick()
		return
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed * delta
	if !velocity.is_zero_approx():
		last_non_zero_velocity = velocity
	if move_and_slide(): # true if collided
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() is RigidBody2D:
				col.get_collider().apply_force(col.get_normal() * -push_force)
	flip_h()
	facing_direction = _calculate_facing_direction()
	state.tick()

func _palay_sync_anim(anim_name: String) -> void: 
	for child in visual.get_children():
		if child is AnimatedSprite2D:
			child.stop()
			child.play(anim_name)

func _calculate_facing_direction() -> Vector2:
	var lnzv:  = last_non_zero_velocity
	if abs(lnzv.x) > abs(lnzv.y):
		if lnzv.x < 0: return Vector2.LEFT
		if lnzv.x > 0: return Vector2.RIGHT
	else:
		if lnzv.y < 0: return Vector2.UP
		if lnzv.x > 0: return Vector2.DOWN
	return Vector2.DOWN

func _get_anim_direction_name(anim_name: String) -> String:
	match facing_direction:
		Vector2.DOWN:
			return anim_name + "_front"
		Vector2.UP:
			return anim_name + "_back"
		Vector2.LEFT, Vector2.RIGHT:
			return anim_name + "_side"
	return anim_name + "_front"

func flip_h() -> void:
	match facing_direction:
		Vector2.LEFT:
			for s in sprites:
				s.flip_h = true
		Vector2.RIGHT:
			for s in sprites:
				s.flip_h = false


func _idle_state() -> Variant:
	if !velocity.is_zero_approx():
		return _walk_state
	return null

func _idle_enter_state() -> void:
	_palay_sync_anim(_get_anim_direction_name("idle"))
	pass

func _walk_state() -> Variant:
	if velocity.is_zero_approx():
		return _idle_state
	return null

func _walk_enter_state() -> void:
	_palay_sync_anim(_get_anim_direction_name("walk"))
	pass

func _talk_state() -> Variant:
	return null

func _talk_enter_state() -> void:
	pass
