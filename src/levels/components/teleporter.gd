extends Node2D

@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var target_marker = $Marker2D

var is_used: bool = false

func _ready() -> void:
	# Connexion automatique du signal
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Si déjà utilisé, on ne fait rien
	if is_used:
		return

	# Vérification du joueur
	var is_player = body.is_in_group("player") or body.is_in_group("Player") or body.name.to_lower().begins_with("player")
	
	if is_player:
		is_used = true

		# 1. Téléportation du joueur au Point B
		body.global_position = target_marker.global_position

		# 2. Désactivation du trigger pour qu'il ne s'active plus jamais
		# (call_deferred est OBLIGATOIRE dans Godot quand on modifie la physique dans un signal)
		collision_shape.set_deferred("disabled", true)
