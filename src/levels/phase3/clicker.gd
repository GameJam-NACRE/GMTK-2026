class_name Clicker extends Level

@onready var button: Button = $Control/MarginContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	button.pressed.connect(_on_button_pressed)
	EventBus.stop_countdown.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	EventBus.remove_time.emit(5)
