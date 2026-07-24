class_name SwordCollectible extends Collectible

func _ready() -> void:
	super()

func item_effect() -> void:
	EventBus.add_sword.emit()
