extends CanvasLayer

@export var countdown_start: float = 30.0
@export var intro_fade_in_time: float = 2.0
@export var intro_stay_time: float = 3.0
@export var intro_fade_out_time: float = 2.0
@export var intro_fade_out_height: float = 150
@export var intro_start_font_size: int = 80
@export var intro_end_font_size: int = 20
@export var main_fade_in_time: float = 0.1


@onready var panel_container: PanelContainer = $PanelContainer
@onready var main_label: Label = $PanelContainer/Label
@onready var intro_label: Label = $IntroLabel
@onready var countdown: Timer = $Timer

const TimeEffectScene = preload("res://scenes/countdown/time_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown.timeout.connect(_on_countdown_timeout)
	EventBus.add_time.connect(_on_add_time)
	EventBus.remove_time.connect(_on_remove_time)

	countdown.start(countdown_start + intro_fade_in_time + intro_stay_time + intro_fade_out_time + main_fade_in_time)
	play_intro_sequence()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var time_left: float = countdown.time_left

	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	var milliseconds: int = int((time_left - int(time_left)) * 100)

	var formated_countdown = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

	main_label.text = formated_countdown
	intro_label.text = formated_countdown

func play_intro_sequence() -> void:
	panel_container.modulate.a = 0.0
	intro_label.modulate.a = 0.0
	intro_label.add_theme_font_size_override("font_size", intro_start_font_size)

	var tween = create_tween()

	tween.tween_property(intro_label, "modulate:a", 1.0, intro_fade_in_time)

	tween.tween_interval(intro_stay_time)

	tween.chain().tween_callback(func(): EventBus.intro_countdown_end.emit())
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(intro_label, "position:y", intro_label.position.y - intro_fade_out_height, intro_fade_out_time)
	tween.parallel().tween_property(intro_label, "modulate:a", 0.0, intro_fade_out_time)
	tween.parallel().tween_property(intro_label, "theme_override_font_sizes/font_size", intro_end_font_size, intro_fade_out_time)

	tween.chain().tween_property(panel_container, "modulate:a", 1.0, main_fade_in_time)


func _on_countdown_timeout() -> void:
	main_label.text = "00:00:00"
	EventBus.countdown_end.emit()
	print("Game Over")

func _on_add_time(sec: int) -> void:
	if countdown.is_stopped():
		return

	_create_pop_up_effect(sec)

	var new_time = countdown.time_left + sec
	countdown.start(new_time)

func _on_remove_time(sec: int) -> void:
	if countdown.is_stopped():
		return

	_create_pop_up_effect(-sec)

	var new_time = countdown.time_left - sec

	if new_time <= 0.0 :
		countdown.stop()
		_on_countdown_timeout()
	else :
		countdown.start(new_time)

func _create_pop_up_effect(amount: int) -> void:
	var effect = TimeEffectScene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = panel_container.global_position + (panel_container.size / 2.0)
	effect.start(amount)




func _unhandled_input(event: InputEvent) -> void:
	# push_warning("test input pour countdown a enlever")
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_P:
			EventBus.add_time.emit(5)
		if event.keycode == KEY_O:
			EventBus.remove_time.emit(5)
