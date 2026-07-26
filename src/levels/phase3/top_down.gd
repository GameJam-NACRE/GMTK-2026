extends Level

@export var normal_speed: float = 100.0   # Vitesse normale de montée
@export var slow_speed: float = 10.0       # Vitesse pendant le ralentissement
@export var shake_power: float = 20.0       # Intensité du tremblement

var current_speed: float = 100.0
var is_slowed: bool = false
var camera: Camera2D = null

# Récupération des nœuds
@onready var sol_tilemap: TileMapLayer = $TileMapLayer # Ou $TileMap selon le nom de ton sol
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	# Récupère la caméra du joueur
	super()
	EventBus.enable_top_down.emit()
	if has_node("Player/Camera2D"):
		camera = $Player/Camera2D
	else:
		camera = get_viewport().get_camera_2d()

	camera.offset.y = -200.0

func _process(delta: float) -> void:
	# En Godot, Y négatif = vers le haut !
	var movement = Vector2.UP * current_speed * delta

	# 1. Fait monter le sol
	if sol_tilemap:
		sol_tilemap.position += movement

	# 2. Fait monter le joueur pour qu'il suive le sol
	if player:
		player.position += movement

# Appelé quand le joueur touche un obstacle
func trigger_obstacle_hit() -> void:
	if is_slowed:
		return

	_apply_hit_effects()

func _apply_hit_effects() -> void:
	is_slowed = true
	current_speed = slow_speed

	# --- Effet de Tremblement (Shake) ---
	if camera:
		# On stoppe un éventuel tween précédent
		var shake_tween = create_tween()
		var base_offset = camera.offset # Garde Vector2(0, -200)
		var duration = 0.04 # Vitesse de chaque secousse

		for i in range(6):
			# On calcule un décalage AUTOUR de l'offset de base (-200)
			var random_shake = Vector2(
				randf_range(-shake_power, shake_power),
				randf_range(-shake_power, shake_power)
			)
			shake_tween.tween_property(camera, "offset", base_offset + random_shake, duration)

		# On réinitialise exactement à la position initiale à la fin
		shake_tween.tween_property(camera, "offset", base_offset, duration)

	# --- Ralentissement pendant 2 secondes ---
	await get_tree().create_timer(0.2).timeout
	current_speed = normal_speed
	is_slowed = false
