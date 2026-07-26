class_name Level2 extends Level

@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	EventBus.countdown_hud_mode.emit()
	player.has_sword = true

