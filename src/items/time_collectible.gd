class_name TimeCollectible extends Collectible

@export var seconds : int = 5

func _ready() -> void:
	super()

func item_effect() -> void:
	EventBus.add_time.emit(seconds)
