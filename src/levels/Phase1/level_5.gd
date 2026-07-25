class_name Level5 extends Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	EventBus.countdown_hud_mode.emit()
