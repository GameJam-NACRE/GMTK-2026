extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

func _ready() -> void:
	self.add_to_group("player")

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
	
	if Input.is_action_just_released("move_up") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4
	
	if Input.is_action_pressed("move_down") and is_on_floor():
		animated_sprite_2d.animation = "crouch"

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		animated_sprite_2d.animation = "attack_1"
	elif Input.is_action_just_pressed("attack") and not is_on_floor():
		animated_sprite_2d.animation = "attack_2"

	move_and_slide()
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
