extends Level

@export var normal_speed: float = 100.0
@export var slow_speed: float = 10.0
@export var shake_power: float = 20.0

var current_speed: float = 100.0
var is_slowed: bool = false
var camera: Camera2D = null

@onready var sol_tilemap: TileMapLayer = $TileMapLayer
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	super()
	EventBus.enable_top_down.emit()
	if has_node("Player/Camera2D"):
		camera = $Player/Camera2D
	else:
		camera = get_viewport().get_camera_2d()

	camera.offset.y = -200.0

func _process(delta: float) -> void:
	var movement = Vector2.UP * current_speed * delta

	if sol_tilemap:
		sol_tilemap.position += movement

	if player:
		player.position += movement

func trigger_obstacle_hit() -> void:
	if is_slowed:
		return

	_apply_hit_effects()

func _apply_hit_effects() -> void:
	EventBus.add_time.emit(10)

	is_slowed = true
	current_speed = slow_speed

	if camera:
		var shake_tween = create_tween()
		var base_offset = camera.offset
		var duration = 0.04

		for i in range(6):
			var random_shake = Vector2(
				randf_range(-shake_power, shake_power),
				randf_range(-shake_power, shake_power)
			)
			shake_tween.tween_property(camera, "offset", base_offset + random_shake, duration)

		shake_tween.tween_property(camera, "offset", base_offset, duration)

	await get_tree().create_timer(0.2).timeout
	current_speed = normal_speed
	is_slowed = false
