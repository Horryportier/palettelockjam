extends Node

@export_group("nodes")
@export var subviewport: SubViewport
@export var sprite_stack: SpriteStack
@export var camera: Camera2D


@export_group("setup")
@export var sprite_stack_rotation: float
@export var save_incremental: bool
@export var clear_output: bool



@export_group("export")
@export var output_path: String
## file name [without extention]
@export var file_name: String
@export var sprite_sheet_save_path: String
@export var sprite_sheet_file_name: String

var current_angle: float

var saved_paths: Array[String]

func _ready() -> void:
	align()
	if save_incremental:
		for i: int in 360 / sprite_stack_rotation:
			await save(i)
			current_angle += sprite_stack_rotation
			sprite_stack.stack_rotation = current_angle
			await get_tree().create_timer(0.2).timeout
		current_angle = 0
		await get_tree().create_timer(1).timeout
		sprite_sheet()
		await get_tree().create_timer(2).timeout
		if clear_output:
			_clean_output()


	else:
		sprite_stack.stack_rotation = sprite_stack_rotation
		save(0)
	
func align() -> void:
	var sprite_height: int = sprite_stack.texture.get_height()
	subviewport.size = Vector2.ONE * sqrt(pow(sprite_height, 2) + pow(sprite_height, 2))
	@warning_ignore("integer_division")
	sprite_stack.global_position = subviewport.size * 0.5 + Vector2(0, sprite_stack.hframes / 2)
	camera.global_position = subviewport.size * 0.5

func save(index: int) -> void:
	await  RenderingServer.frame_post_draw
	var texture: = subviewport.get_texture()
	var image: = texture.get_image()
	image.convert(Image.FORMAT_RGBA8)
	var final_path: String
	if save_incremental:
		final_path = "%s%s_%s.png" % [output_path, file_name, str(index)]
	else:
		final_path = "%s%s.png" % [output_path, file_name]
	image.save_png(final_path)


func _clean_output() -> void:
	var paths: = DirAccess.get_files_at(output_path)
	var dir: = DirAccess.open(output_path)
	for path in paths:
		if path.ends_with(".png"):
			dir.remove(path)

func sprite_sheet() -> void:
	var paths: = DirAccess.get_files_at(output_path)
	var args: PackedStringArray 
	var save_path_trimed: = output_path.trim_prefix("res://")
	for path in paths:
		if path.ends_with(".png"):
			args.append(save_path_trimed + path)
	args.append("--sheet=%s%s.png" % [sprite_sheet_save_path.trim_prefix("res://"), sprite_sheet_file_name])
	var dir: Dictionary = OS.execute_with_pipe("aseprite", args)
	await get_tree().create_timer(2).timeout
	if dir.has("pid"):
		OS.kill(dir["pid"])
