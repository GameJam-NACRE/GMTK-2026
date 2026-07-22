class_name CoinCollectible extends Collectible

func _ready() -> void:
	super()

func item_effect() -> void:
	EventBus.add_coin.emit()
