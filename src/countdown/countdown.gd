extends CanvasLayer

@export var countdown_start: float = 30.0
@export var intro_fade_in_time: float = 2.0
@export var intro_stay_time: float = 3.0
@export var intro_fade_out_time: float = 2.0
@export var intro_fade_out_height: float = 150
@export var intro_start_font_size: int = 80
@export var intro_end_font_size: int = 20
@export var main_fade_in_time: float = 0.1

@export var hud_mode_fade_time: float = 1.0
@export var clicker_mode_fade_time: float = 1.0

@export var critic_countdown: float = 20.0

@onready var panel_container: PanelContainer = $PanelContainer
@onready var main_label: Label = $PanelContainer/Label
@onready var intro_label: Label = $IntroLabel
@onready var countdown: Timer = $Timer
@onready var clicker_countdown: VBoxContainer = $CenterContainer/ClickerCountdown
@onready var clicker_label: Label = $CenterContainer/ClickerCountdown/ClickerLabel

var hud_mode_on: bool = true

const TimeEffectScene = preload("res://scenes/countdown/time_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown.timeout.connect(_on_countdown_timeout)
	EventBus.add_time.connect(_on_add_time)
	EventBus.remove_time.connect(_on_remove_time)
	EventBus.countdown_clicker_mode.connect(_set_mode_clicker)
	EventBus.countdown_hud_mode.connect(_set_mode_hud)
	EventBus.stop_countdown.connect(_on_stop_countdown)

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
	clicker_label.text = formated_countdown

	if time_left <= critic_countdown:
		countdown.set_paused(false)

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

func _on_stop_countdown() -> void:
	countdown.set_paused(true)

func _on_countdown_timeout() -> void:
	main_label.text = "00:00:00"
	EventBus.countdown_end.emit()
	print("Game Over")

func _set_mode_hud() -> void:
	if not hud_mode_on:
		var tween = create_tween()

		tween.tween_property(panel_container, "modulate:a", 1.0, hud_mode_fade_time)
		tween.parallel().tween_property(clicker_countdown, "modulate:a", 0.0, clicker_mode_fade_time)
		hud_mode_on = true

func _set_mode_clicker() -> void:
	if hud_mode_on:
		var tween = create_tween()

		tween.tween_property(panel_container, "modulate:a", 0.0, hud_mode_fade_time)
		tween.parallel().tween_property(clicker_countdown, "modulate:a", 1.0, clicker_mode_fade_time)
		hud_mode_on = false


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
	if hud_mode_on:
		main_label.add_child(effect)
		effect.global_position = panel_container.global_position + (panel_container.size / 2.0)
	else:
		clicker_label.add_child(effect)
		effect.global_position = clicker_countdown.global_position + (clicker_countdown.size / 2.0)
	effect.start(amount)




func _unhandled_input(event: InputEvent) -> void:
	# push_warning("test input pour countdown a enlever")
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_P:
			EventBus.add_time.emit(5)
		if event.keycode == KEY_O:
			EventBus.remove_time.emit(5)
