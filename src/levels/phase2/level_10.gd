extends Level
class_name Level10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	EventBus.countdown_hud_mode.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
