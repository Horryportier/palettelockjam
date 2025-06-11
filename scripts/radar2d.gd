class_name Radar2D
extends Area2D

## Radar2D extends from Area2D and stores all nodes that meed requirements.
##
## Radar2D normally filters by group but it can also use custom filters that have to be set by parent script
## when use_custom_filter is selected radar2D will track all nodes/areas that meet conditons

@export var group: String = ""
@export var use_custom_filter: = false
@export var debug: bool 

## body_filter callable should take Node2D and return bool
var body_filter: Callable = func (_body: Node2D): return false
## area_filter callable should take Area2D and return bool
var area_filter: Callable = func (_area: Area2D): return false

var bodies: Array[Node2D] = []
var areas: Array[Area2D] = []

signal area_tracked(area: Area2D)
signal area_untracked(area: Area2D)

signal body_tracked(body: Node2D)
signal body_untracked(body: Node2D)


func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if debug:
		area_tracked.connect(func(area: Area2D)-> void: print(self, "area tracked", area))
		area_untracked.connect(func(area: Area2D)-> void: print(self, "area untracked", area))
		body_tracked.connect(func(body: Node2D)-> void: print(self, "body tracked", body))  	
		body_untracked.connect(func(body: Node2D)-> void: print(self, "body untracked", body))

func _on_area_entered(area: Area2D):
	if use_custom_filter:
		if area_filter.call(area):
			areas.append(area)
			area_tracked.emit(area)
	else:
		if area.is_in_group(group):
			areas.append(area)
			area_tracked.emit(area)

func _on_area_exited(area: Area2D):
	var index = areas.find(area)
	if index != -1: 
		area_untracked.emit(areas.pop_at(index))

func _on_body_entered(body: Node2D):
	if use_custom_filter:
		if body_filter.call(body):
			bodies.append(body)
			body_tracked.emit(body)
	else:
		if body.is_in_group(group):
			bodies.append(body)
			body_tracked.emit(body)

func _on_body_exited(body: Node2D):
	var index = bodies.find(body)
	if index != -1: 
		body_untracked.emit(bodies.pop_at(index))


