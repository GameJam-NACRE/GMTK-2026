class_name Level3 extends Level

@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	EventBus.countdown_hud_mode.emit()
	EventBus.has_5_coins.connect(_has_5_coins)
	player.has_sword = true

func _has_5_coins() -> void:
	EventBus.launch_dialogue.emit(4)
