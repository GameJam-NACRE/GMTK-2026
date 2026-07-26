@abstract
class_name Collectible extends Area2D

var is_collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_to_group("collectible")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if is_collected == true:
		return

	item_effect()
	queue_free()

@abstract
func item_effect() -> void
