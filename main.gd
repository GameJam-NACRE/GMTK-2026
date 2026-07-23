extends Node

func _ready() -> void:
	LevelManager.level_container = $LevelContainer
	GameManager.next_level()

