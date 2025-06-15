extends CanvasLayer

@onready var start: Button = %Start
@onready var quit: Button = %Quit
@onready var mute: Button = %Mute
@onready var volume: Slider = %Volume

@export var audio_curver: Curve

func _ready() -> void:
	start.pressed.connect(func () -> void: hide(); Game.start_game.emit())
	quit.pressed.connect(Game.game_quit)
	mute.toggled.connect(_on_mute_toggled)
	volume.value_changed.connect(_on_value_changed)

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, audio_curver.sample(value))
