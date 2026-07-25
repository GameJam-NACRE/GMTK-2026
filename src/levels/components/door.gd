extends Area2D

@export var is_open: bool = false
@export var dialogue_id: int = 0
@export var key: bool = false

@onready var static_body_collision: CollisionShape2D = $StaticBody2D/DoorCollision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_in_zone: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	EventBus.no_key.connect(_on_no_key)
	EventBus.one_key.connect(_on_one_key)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_zone and not is_open and event.is_action_pressed("open_door"):
		if key:
			EventBus.got_key.emit()
		else:
			is_open = true
			static_body_collision.set_deferred("disabled", true)
			animated_sprite.play("open")


func _on_no_key() -> void:
	EventBus.launch_dialogue.emit(dialogue_id)

func _on_one_key() -> void:
	is_open = true
	static_body_collision.set_deferred("disabled", true)
	animated_sprite.play("open")
	EventBus.use_key.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
