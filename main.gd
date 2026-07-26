extends Node

func _ready() -> void:
	LevelManager.level_container = $LevelContainer
	EventBus.intro_countdown_end.connect(_on_intro_countdown_end)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_intro_countdown_end() -> void:
	GameManager.next_level()
