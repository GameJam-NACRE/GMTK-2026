class_name SwordCollectible extends Collectible

func _ready() -> void:
	super()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if is_collected == true:
		return

	item_effect()
	queue_free()

func item_effect() -> void:
	EventBus.add_sword.emit()
