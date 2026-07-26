@tool
extends Area2D

@export var texture: Texture2D:
	set(value):
		texture = value
		if is_node_ready() and $Sprite2D:
			$Sprite2D.texture = value

@export var fall_gravity: float = 400.0
@export var max_fall_speed: float = 600.0

var fall_speed: float = 0.0
var is_falling: bool = false
var is_being_destroyed: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	if texture and sprite:
		sprite.texture = texture

	if not Engine.is_editor_hint():
		notifier.screen_entered.connect(_on_screen_entered)
		body_entered.connect(_on_body_entered)

func _on_screen_entered() -> void:
	start_falling_structure()

func start_falling_structure() -> void:
	if is_falling:
		return
	
	is_falling = true

	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.has_method("start_falling_structure"):
			area.start_falling_structure()

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not is_falling:
		return

	fall_speed += fall_gravity * delta
	fall_speed = min(fall_speed, max_fall_speed)
	position.y += fall_speed * delta

func _on_body_entered(body: Node2D) -> void:
	
	var is_player = body.is_in_group("player") or body.is_in_group("Player") or body.name.to_lower().begins_with("player")
	
	if is_player:
		
		var level = get_tree().current_scene
		
		if not (level and level.has_method("trigger_obstacle_hit")):
			level = find_level_node(self)
		
		if level and level.has_method("trigger_obstacle_hit"):
			level.trigger_obstacle_hit()
		else:
			print("ERREUR: Impossible de trouver un niveau avec la fonction trigger_obstacle_hit()")
		
		destroy_structure()

func find_level_node(node: Node) -> Node:
	var current = node
	while current:
		if current.has_method("trigger_obstacle_hit"):
			return current
		current = current.get_parent()
	return null

func destroy_structure() -> void:
	if is_being_destroyed:
		return
	
	is_being_destroyed = true

	var overlapping_areas = get_overlapping_areas()
	queue_free()

	for area in overlapping_areas:
		if area.has_method("destroy_structure"):
			area.destroy_structure()
