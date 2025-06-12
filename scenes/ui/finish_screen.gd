extends CanvasLayer

@onready var score: RichTextLabel  = %Score
@onready var state_label: RichTextLabel  = %State

func _ready() -> void:
	Game.run_finished.connect(setup)

func setup(time_elapsed: float, state: Game.FailureState) -> void:
	show()
	if state == Game.FailureState.None:
		state_label.text = "Ending C [Dedicated Fan]"
		var minutes = time_elapsed / 60
		var seconds = fmod(time_elapsed, 60)
		var milliseconds = fmod(time_elapsed, 1) * 100
		var time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
		score.text = "Time: [color=ee6a7c]%s[/color]" % [time_string]
		return
	score.hide()
	match state:
		Game.FailureState.AbandonedRun:
			state_label.text = "Ending A [Fake Otaku]"
		Game.FailureState.RunnedOutOfTime:
			state_label.text = "Ending B [Noodle Arms]"
