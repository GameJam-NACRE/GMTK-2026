class_name Final extends Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.countdown_final_mode.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
