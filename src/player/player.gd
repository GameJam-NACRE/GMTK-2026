extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

var is_knocked_back: bool = false

var key: bool = false
var coins: int = 0

func _ready() -> void:
	self.add_to_group("player")
	EventBus.add_key.connect(_on_add_key)
	EventBus.add_coin.connect(_on_add_coin)
	EventBus.enemy_contact.connect(_on_enemy_contact)

func _on_add_key() -> void:
	key = true

func _on_add_coin() -> void:
	coins += 1

func _on_use_key() -> void:
	key = false

func _on_enemy_contact(enemy_pos: Vector2) -> void:
	velocity = (self.position - enemy_pos).normalized() * 500
	if is_on_floor():
		velocity.y = -200
	is_knocked_back = true
	await get_tree().create_timer(0.25).timeout
	is_knocked_back = false

func _physics_process(delta: float) -> void:
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "walk"
	else:
		animated_sprite_2d.animation = "idle"

	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jump"

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("move_down") and is_on_floor():
		animated_sprite_2d.animation = "crouch"

	if not is_knocked_back:
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true

	move_and_slide()
	
