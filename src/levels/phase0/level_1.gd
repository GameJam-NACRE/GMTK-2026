class_name Level1 extends Level

const TimeCollectibleScene = preload("res://scenes/items/time_collectible.tscn")
const CASE: float = 80.0

@export var shower_duration: float = 20.0
@export var clock_frequency: float = 1.5

@onready var player: CharacterBody2D = $Player
@onready var shower_timer: Timer = $ShowerTimer

var shower_active: bool = false
var shower_time_acc: float = 0.0

func _ready() -> void:
	super()
	EventBus.countdown_hud_mode.emit()
	EventBus.countdown_critical.connect(_on_countdown_critical)
 
	shower_timer.one_shot = true
	shower_timer.timeout.connect(_on_shower_timer_timeout)

	if dialogue_label:
		dialogue_label.visible_characters = 0
 
	await ScreenFader.fade_in(screen_fade_in)
 
 
func _process(delta: float) -> void:
	if not shower_active:
		return

	shower_time_acc += delta
	var interval = randf_range(1 - clock_frequency, 2.5 - clock_frequency)
	if shower_time_acc >= interval:
		shower_time_acc -= interval
		add_time_collectible(randf_range(264, 416), randi_range(0, 1), randi_range(0, 5))
 
 
func start_shower(duration: float) -> void:
	shower_active = true
	shower_time_acc = 0.0
	shower_timer.start(duration)
 
 
func _on_shower_timer_timeout() -> void:
	shower_active = false
 
 
func _on_countdown_critical() -> void:
	start_shower(shower_duration)
 
 
func add_time_collectible(height_above_player: float, case: int, duration: int) -> void:
	var time_item = TimeCollectibleScene.instantiate()
	add_child(time_item)
	time_item.global_position.x = player.global_position.x + CASE * case
	time_item.global_position.y = player.global_position.y - height_above_player
 
	var target_y = player.global_position.y
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(time_item, "global_position", Vector2(time_item.global_position.x, target_y), 0.2 * duration)
