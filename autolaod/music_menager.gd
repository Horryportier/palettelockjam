extends AudioStreamPlayer

func _ready() -> void:
	Game.start_game.connect(play)
