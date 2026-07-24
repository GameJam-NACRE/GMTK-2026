@abstract
class_name Level extends Node2D

@export var dialogues: Array[DialogueData] = []
@export var screen_fade_in: float
@export var screen_fade_out : float

@onready var flag_area: Area2D = $FlagArea
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var dialogue_label: RichTextLabel = $UI/MarginContainer/DialogueLabel

var active_dialogue_tween: Tween

func _ready() -> void:
	await ScreenFader.fade_in(screen_fade_in)
	EventBus.launch_dialogue.connect(_on_launch_dialogue)
	EventBus.flag_reached.connect(_on_flag_reached)

	if dialogue_label:
		dialogue_label.visible_characters = 0

func _on_launch_dialogue(id: int) -> void :
	var dialogue_data = _get_dialogue_by_id(id)

	if dialogue_data == null :
		push_warning("Level: Dialogue Queue: Wrong Dialogue ID -> ", id)
		return

	_play_dialogue(dialogue_data)

func _get_dialogue_by_id(id: int) -> DialogueData:
	for d in dialogues:
		if d and d.id == id:
			return d

	return null

func _play_dialogue(data: DialogueData) -> void:
	if active_dialogue_tween and active_dialogue_tween.is_running():
		active_dialogue_tween.kill()

	if audio_player.playing:
		audio_player.stop()
	
	dialogue_label.modulate.a = 1.0
	dialogue_label.visible_characters = 0
	dialogue_label.text = data.text

	if data.audio:
		audio_player.stream = data.audio
		audio_player.play()

	_animate_and_hide_subtitles(data)


func _animate_and_hide_subtitles(data: DialogueData) -> void:
	active_dialogue_tween = create_tween()

	var text_content = data.text
	
	for i in range(text_content.length()):
		active_dialogue_tween.tween_property(dialogue_label, "visible_characters", i + 1, data.dial_char_speed)
		
		var current_char = text_content[i]
		if current_char in [".", "!", "?", ":"]:
			active_dialogue_tween.tween_interval(data.dial_long_pause)
		elif current_char in [",", ";"]:
			active_dialogue_tween.tween_interval(data.dial_short_pause)

	if data.audio:
		var display_time = data.audio.get_length()
		active_dialogue_tween.tween_interval(max(data.dial_time_if_audio, display_time - (text_content.length() * data.dial_char_speed)))
	else:
		active_dialogue_tween.tween_interval(data.dial_time_if_no_audio)

	active_dialogue_tween.tween_property(dialogue_label, "modulate:a", 0.0, 0.5)
	
	active_dialogue_tween.tween_callback(func(): dialogue_label.text = "")


func _on_flag_reached() -> void:
	end_level()

func end_level() -> void:
	await ScreenFader.fade_out(screen_fade_out)
	EventBus.level_ended.emit()
