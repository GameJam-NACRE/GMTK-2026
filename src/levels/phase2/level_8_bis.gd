extends Level
class_name Level8Bis


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	EventBus.launch_dialogue.emit(0)
