@abstract
class_name Level extends Node2D

@export var dialogue_queue: Array[String] = []

func _ready() -> void:
	EventBus.launch_dialogue.connect(_on_launch_dialogue)

func _on_launch_dialogue(id: int) -> void :
	if (id + 1 > dialogue_queue.size() || id < 0) :
		push_warning("Level: Dialogue Queue: Wrong Dialogue ID")
		return
	# Launch Text + Voc du dialogue 

func end_level() -> void:
	EventBus.level_ended.emit()
