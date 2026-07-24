extends Node

var current_level: int = -1

var level_queue: Array[PackedScene] = [
	preload("res://scenes/levels/phase3/clicker.tscn"),
	]

func _ready() -> void:
	EventBus.level_ended.connect(_on_level_ended)

func next_level() -> void :
	current_level += 1
	if current_level >= level_queue.size():
		push_warning("FIN DES NIVEAUX")
		return
	push_warning("level %d is loading" % [current_level])
	if "clicker" in level_queue[current_level].resource_path:
		EventBus.countdown_clicker_mode.emit()
	else:
		EventBus.countdown_hud_mode.emit()

	LevelManager.load_level(level_queue[current_level])

func _on_level_ended() -> void:
	next_level()
