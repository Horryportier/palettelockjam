extends CanvasLayer


@export var score: RichTextLabel 

func _ready() -> void:
	Game.run_finished.connect(setup)

func setup(time_elapsed: float) -> void:
	show()
	var minutes = time_elapsed / 60
	var seconds = fmod(time_elapsed, 60)
	var milliseconds = fmod(time_elapsed, 1) * 100
	var time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	score.text = "Time: [color=ee6a7c]%s[/color]" % [time_string]
