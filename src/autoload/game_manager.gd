extends Node

var saved_countdown_time: float = -1.0
var current_level: int = -1

var level_queue: Array[PackedScene] = [
	preload("res://scenes/levels/phase0/level_0.tscn"),
	preload("res://scenes/levels/phase2/level_8.tscn"),
	preload("res://scenes/levels/phase3/clicker.tscn"),
	preload("res://scenes/levels/phase4/final.tscn"),
]

const SAVE_PATH = "user://gamesave.cfg"

func _ready() -> void:
	EventBus.level_ended.connect(_on_level_ended)
	EventBus.send_time_countdown.connect(_on_send_time_countdown)

	if FileAccess.file_exists(SAVE_PATH):
		load_game()

func next_level() -> void:
	current_level += 1
	if current_level >= level_queue.size():
		push_warning("FIN DES NIVEAUX")
		return
		
	push_warning("level %d is loading" % [current_level])

	EventBus.ask_time_countdown.emit()

	LevelManager.load_level(level_queue[current_level])

func _on_level_ended() -> void:
	next_level()

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err != OK:
		push_error("Couldn't load save !")
		next_level()
		return

	current_level = config.get_value("Progress", "current_level", 0)
	saved_countdown_time = config.get_value("Progress", "countdown_value", 60.0)

	print("Game loaded: level %d with %d seconds left" % [current_level, saved_countdown_time])

	LevelManager.load_level(level_queue[current_level])

func _on_send_time_countdown(time: float) -> void:
	if current_level < 0:
		return
		
	var config = ConfigFile.new()
	config.set_value("Progress", "current_level", current_level)
	config.set_value("Progress", "countdown_value", time)

	var err = config.save(SAVE_PATH)

	if err == OK:
		print("Game saved at level %d with %d secondes left" % [current_level, time])
	else:
		push_error("Error while saving : ", err)
