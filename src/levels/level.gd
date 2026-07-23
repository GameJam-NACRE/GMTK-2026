@abstract
class_name Level extends Node2D

@export var dialogue_queue: Array[String] = []
@export var screen_fade_in: float
@export var screen_fade_out : float


@onready var flag_area: Area2D = $FlagArea

func _ready() -> void:
	await ScreenFader.fade_in(screen_fade_in)
	EventBus.launch_dialogue.connect(_on_launch_dialogue)
	EventBus.flag_reached.connect(_on_flag_reached)

func _on_launch_dialogue(id: int) -> void :
	if (id + 1 > dialogue_queue.size() || id < 0) :
		push_warning("Level: Dialogue Queue: Wrong Dialogue ID")
		return
	# Launch Text + Voc du dialogue 

func _on_flag_reached() -> void:
	end_level()

func end_level() -> void:
	await ScreenFader.fade_out(screen_fade_out)
	EventBus.level_ended.emit()
