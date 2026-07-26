extends Level
class_name Level8Ter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	EventBus.launch_dialogue.emit(0)

	await get_tree().create_timer(16.5).timeout

	EventBus.stop_countdown.emit()
