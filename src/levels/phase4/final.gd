class_name Final extends Level

@export_multiline var final_text: String

@onready var timer_audio_25: Timer = $TimerAudio25
@onready var timer_audio_10: Timer = $TimerAudio10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	EventBus.countdown_final_mode.emit()
	EventBus.countdown_end.connect(_on_countdown_end)

	timer_audio_25.timeout.connect(_on_timer_audio_25_timeout)
	timer_audio_10.timeout.connect(_on_timer_audio_10_timeout)

	print("dialogue 1")
	EventBus.launch_dialogue.emit(0)
	
func _on_timer_audio_25_timeout() -> void:
	EventBus.launch_dialogue.emit(1)

func _on_timer_audio_10_timeout() -> void:
	# Déclenché quand le compteur atteint 10s
	EventBus.launch_dialogue.emit(2)

func create_file_on_desktop() -> void:
	var desktop_path := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var file_path := desktop_path.path_join("FINAL_GOODBYE.txt")
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(final_text)
		file.close()

func _on_countdown_end() -> void:
	create_file_on_desktop()
	await get_tree().create_timer(1.5).timeout

	OS.crash("this was fun")
