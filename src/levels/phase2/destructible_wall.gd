extends StaticBody2D

@export var health: int = 1

func take_damage(amount: int = 1) -> void:
	health -= amount
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)

	if health <= 0:
		destroy()

func destroy() -> void:
	queue_free()
