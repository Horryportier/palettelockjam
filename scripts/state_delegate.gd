class_name StateDelegate
extends RefCounted

###################################################################################################
## StateDelagete: is simple finate state machine class that uses function pointers to menage state #
###################################################################################################

signal state_changed(old_state: Callable, new_state: Callable)

class State:
	## state tick is main loop of state that returns null when no state change and other state function when state changes
	var state_tick: Callable
	## state enter is called when state is being chanded its an setup function that returns nothing 
	var state_enter: Callable
	## state exit is called when current state is invalid 
	var state_exit: Callable
	var state_name: String = "NONE"

	func _init(state: Callable, enter: Callable, exit: Callable) -> void:
		state_tick = state
		state_enter = enter
		state_exit = exit
	
var _registry: Dictionary = {}

## if set to true it will print state transition 
var debug: bool = false:
	set(val):
		debug = val
		if debug:
			state_changed.connect(_on_state_changed)
		else:
			state_changed.disconnect(_on_state_changed)

var _state_tansition_complete: bool = false

var _current_state: Callable: 
	set(val):
		if !_registry.has(val):
			push_warning("trying to asign non existing state [%s]" % [val])
			return
		if _current_state != val:
			_state_tansition_complete = false
			var state: State = _registry.get(_current_state)
			if state:
				await state.state_exit.call()
			state = _registry.get(val)
			await state.state_enter.call()
			state_changed.emit(_current_state, val) 
			_current_state = val
			_state_tansition_complete = true
		

var _enter_state_fn_default: = func() -> void: return
var _exit_state_fn_default: = func() -> void: return 


## add state ads state to registry you need to provide at least tick state function 
## name defaults to empty string "", state_enter and state_exit default to empty fuctions
func add_state(state: Callable, name: String = "",  state_enter: Callable = _enter_state_fn_default, state_exit: Callable = _exit_state_fn_default) -> void:
	_registry[state] = State.new(state, state_enter, state_exit)
	if name != "":
		_registry.get(state).state_name = name


## set startarting state
func set_default_state(state: Callable) -> void:
	if _registry.has(state): 
		_current_state = state
	else:
		push_error("registry dose not have [%s] state" % [state])

## sets current state can be used oudside of the state functions
func set_state(state: Callable) -> void:
	if !_registry.has(state):
		push_error("registry dose not have [%s] state" % [state])
		return
	_current_state = state

## gets states name 
func get_state_name(state: Callable) -> String:
	if !_registry.has(state):
		push_error("registry dose not have [%s] state" % [state])
		return "INVALID STATE"
	return _registry.get(state).state_name

	
## when called it will execute current state
## you can run it in proccess or on timer depending on your needs 
func tick() -> void:
	if !_state_tansition_complete:
		return
	var state: State = _registry.get(_current_state)
	var res: Variant = await state.state_tick.call()
	match typeof(res):
		TYPE_NIL:
			return
		TYPE_CALLABLE:
			if !_registry.has(res):
				push_error("current state returned invalid state function")
				return 
			var s: Variant = _registry.get(res)
			_current_state = s.state_tick


## prints state registry data
func print_registry() -> void: 
	for v: Callable in _registry.keys():
		printt(_registry.get(v).state_name, v == _registry.get(v).state_tick)

## Cheacks if current_state is equal to passed state
func is_state(state: Callable) -> bool:
	if state == _current_state:
		return true
	return false

func _on_state_changed(old_state: Callable, new_state: Callable) -> void:
	var old_state_name: String = "NONE"
	if _registry.has(old_state):
		old_state_name = _registry.get(old_state).state_name
	print("state changed from [color=orange]%s[/color] to [color=green]%s[/color]" % 
	[old_state_name, _registry.get(new_state).state_name])
