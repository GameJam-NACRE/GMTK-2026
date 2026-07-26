extends Node2D

@export var speed: float = 200.0

@onready var wall: AnimatableBody2D = $AnimatableBody2D
@onready var target_marker: Marker2D = $Marker2D
@onready var trigger_zone: Area2D = $Area2D

var is_moving: bool = false

func _ready() -> void:
	# On connecte le signal du trigger automatiquement par le code !
	trigger_zone.body_entered.connect(_on_trigger_body_entered)

func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	# Déplace le mur vers le Marker2D
	wall.global_position = wall.global_position.move_toward(target_marker.global_position, speed * delta)

	# S'arrête une fois arrivé
	if wall.global_position.is_equal_approx(target_marker.global_position):
		is_moving = false

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name.to_lower().begins_with("player"):
		is_moving = true
