extends Area3D
class_name FlagArea3D

var _triggered = false

func _ready() -> void:
	self.add_to_group("level_component")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if _triggered:
		return
	
	_triggered = true
	EventBus.flag_reached.emit()
