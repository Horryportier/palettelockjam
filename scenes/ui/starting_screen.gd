extends CanvasLayer

@onready var start: Button = %Start
@onready var quit: Button = %Quit
@onready var mute: Button = %Mute
@onready var volume: Slider = %Volume

func _ready() -> void:
	start.pressed.connect(func () -> void: hide(); Game.start_game.emit())
	quit.pressed.connect(Game.game_quit)

