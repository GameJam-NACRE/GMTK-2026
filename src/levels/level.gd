@abstract
class_name Level extends Node2D

@export var dialogues: Array[DialogueData] = []

@onready var flag_area: Area2D = $FlagArea
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var dialogue_label: RichTextLabel = $UI/MarginContainer/DialogueLabel

var active_dialogue_tween: Tween

func _ready() -> void:
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
	# Launch Text + Voc du dialogue 

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
	
	if data.audio:
		audio_player.stream = data.audio
		audio_player.play()

	if data.text:
		dialogue_label.text = data.text
		dialogue_label.visible_characters = 0

	var duration: float = data.audio.get_length() if data.audio else 3.0
	var total_chars = dialogue_label.get_total_character_count()

	active_dialogue_tween = create_tween()
	active_dialogue_tween.tween_property(dialogue_label, "visible_characters", total_chars, duration)

func _on_flag_reached() -> void:
	end_level()

func end_level() -> void:
	EventBus.level_ended.emit()
