class_name Clicker extends Level

@onready var button: Button = $Control/MarginContainer/Button

@export var custom_cursor: Texture2D
@export var spawn_button: float

var first_press: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	button.pressed.connect(_on_button_pressed)
	EventBus.end_level_clicker.connect(_on_end_level)
	EventBus.countdown_clicker_mode.emit()
	EventBus.launch_dialogue.emit(0)
	
	button.hide()

	await get_tree().create_timer(25.0).timeout

	button.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if custom_cursor:
			Input.set_custom_mouse_cursor(custom_cursor)

func _on_end_level():
	Input.set_custom_mouse_cursor(null)
	end_level()

func _on_button_pressed() -> void:
	if first_press == true:
		first_press = false
		EventBus.launch_dialogue.emit(1)

	EventBus.remove_time.emit(5)
