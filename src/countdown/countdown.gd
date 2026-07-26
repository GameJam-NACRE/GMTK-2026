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

@export_category("final_level")
@export var index: int = 3

@onready var panel_container: PanelContainer = $PanelContainer
@onready var main_label: Label = $PanelContainer/Label
@onready var intro_label: Label = $IntroLabel
@onready var countdown: Timer = $Timer
@onready var clicker_countdown: VBoxContainer = $CenterContainer/ClickerCountdown
@onready var clicker_label: Label = $CenterContainer/ClickerCountdown/ClickerLabel

var initial_panel_pos: Vector2
var is_first_stop: bool = true
var stop_tween: Tween
var hud_mode_on: bool = true
var level_ending_triggered: bool = false

const TimeEffectScene = preload("res://scenes/countdown/time_effect.tscn")

func _ready() -> void:
	countdown.timeout.connect(_on_countdown_timeout)
	EventBus.add_time.connect(_on_add_time)
	EventBus.remove_time.connect(_on_remove_time)
	EventBus.countdown_clicker_mode.connect(_set_mode_clicker)
	EventBus.countdown_hud_mode.connect(_set_mode_hud)
	EventBus.countdown_final_mode.connect(_set_mode_final)
	EventBus.stop_countdown.connect(_on_stop_countdown)
	EventBus.ask_time_countdown.connect(_on_ask_time_countdown)

	var initial_time: float = 0.0

	if GameManager.saved_countdown_time > 0.0:
		initial_time = GameManager.saved_countdown_time
		GameManager.saved_countdown_time = -1.0 # Réinitialise la réserve après lecture
	else:
		initial_time = countdown_start + intro_fade_in_time + intro_stay_time + intro_fade_out_time + main_fade_in_time

	countdown.start(initial_time)

	if GameManager.current_level == -1:
		play_intro_sequence()
	elif GameManager.current_level != index:
		play_classic_sequence()
		await get_tree().process_frame
		initial_panel_pos = panel_container.position

func _process(_delta: float) -> void:
	var time_left: float = countdown.time_left

	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	var milliseconds: int = int((time_left - int(time_left)) * 100)

	var formated_countdown = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

	main_label.text = formated_countdown
	intro_label.text = formated_countdown
	clicker_label.text = formated_countdown

	if not hud_mode_on and not level_ending_triggered and time_left <= critic_countdown:
		level_ending_triggered = true
		countdown.set_paused(false)
		EventBus.end_level_clicker.emit()

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

func play_classic_sequence() -> void:
	var tween = create_tween()
	intro_label.modulate.a = 0.0
	tween.chain().tween_property(panel_container, "modulate:a", 1.0, main_fade_in_time)

func _on_stop_countdown() -> void:
	countdown.set_paused(true)

	# Si un tween de stop était déjà en cours, on l'annule proprement
	if stop_tween and stop_tween.is_running():
		stop_tween.kill()

	# 1. On passe le texte/fond en rouge
	main_label.modulate = Color.RED

	# 2. On déclenche le tremblement
	_shake_node(panel_container, 0.4, 8.0)

	stop_tween = create_tween()

	if is_first_stop:
		is_first_stop = false
		
		# Calcul du centre de l'écran (déduit la moitié de la taille du panel)
		var center_pos = (get_viewport().get_visible_rect().size / 2.0) - (panel_container.size / 2.0)
		
		# Aller rapide au centre
		stop_tween.tween_property(panel_container, "position", center_pos, 0.25)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
		# Pause au centre
		stop_tween.tween_interval(1.0)
		
		# Retour à la position initiale
		stop_tween.tween_property(panel_container, "position", initial_panel_pos, 0.3)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		# Si ce n'est pas la première fois, on s'assure qu'il est bien à sa position initiale
		panel_container.position = initial_panel_pos

func _shake_node(node: Control, duration: float, intensity: float) -> void:
	var shake_tween = create_tween()
	var num_shakes = int(duration / 0.04)
	
	for i in range(num_shakes):
		var shake_offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		shake_tween.tween_property(node, "pivot_offset", shake_offset, 0.04)
		
	shake_tween.tween_property(node, "pivot_offset", Vector2.ZERO, 0.04)

# func _on_stop_countdown() -> void:
# 	countdown.set_paused(true)
#
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
		level_ending_triggered = false

func _set_mode_final() -> void:
	if hud_mode_on:
		var tween = create_tween()
		panel_container.modulate.a = 0.0
		tween.tween_property(clicker_countdown, "modulate:a", 1.0, clicker_mode_fade_time)
		hud_mode_on = false
		level_ending_triggered = false

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
	if new_time <= 0.0:
		countdown.stop()
		_on_countdown_timeout()
	else:
		countdown.start(new_time)

func _on_ask_time_countdown() -> void:
	EventBus.send_time_countdown.emit(countdown.time_left)

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
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_P:
			EventBus.add_time.emit(5)
		if event.keycode == KEY_O:
			EventBus.remove_time.emit(5)
