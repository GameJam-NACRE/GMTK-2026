extends Area2D
class_name DialArea

@export var dialogue_id: int = 0
var _triggered = false

func _ready() -> void:
	self.add_to_group("level_component")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _triggered:
		return
	
	_triggered = true
	EventBus.launch_dialogue.emit(dialogue_id)

