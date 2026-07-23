class_name KeyCollectible extends Collectible

func _ready():
	super()

func item_effect() -> void:
	EventBus.add_key.emit()
