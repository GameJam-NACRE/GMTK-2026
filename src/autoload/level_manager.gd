extends Node

@onready var level_container: Node

var current_level: Level = null

func load_level(level_scene: PackedScene):
	if current_level:
		current_level.queue_free()
		current_level = null

	call_deferred("_do_load_level", level_scene)

func _do_load_level(level_scene: PackedScene) -> void:
	current_level = level_scene.instantiate()
	level_container.add_child(current_level)
	EventBus.level_loaded.emit()
