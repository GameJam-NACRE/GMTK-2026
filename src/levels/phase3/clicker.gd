class_name Clicker extends Level

@onready var button: Button = $Control/MarginContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	button.pressed.connect(_on_button_pressed)
	EventBus.end_level_clicker.connect(_on_end_level)
	EventBus.stop_countdown.emit()
	EventBus.countdown_clicker_mode.emit()

func _on_end_level():
	end_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	EventBus.remove_time.emit(5)
