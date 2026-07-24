extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 300.0
@export var jump_velocity = -500.0
@export var short_hop_divisor = 4.0
@export var attack_speed_scale = 1.5

var is_attacking = false

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed if direction else move_toward(velocity.x, 0, speed)
	
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("move_up") and velocity.y < 0:
		velocity.y = jump_velocity / short_hop_divisor
	
	move_and_slide()

	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		if is_on_floor():
			animated_sprite_2d.play("attack_2", attack_speed_scale, false)
		else:
			animated_sprite_2d.play("attack_1", attack_speed_scale, false)
		return

	if is_attacking:
		return

	if not is_on_floor():
		animated_sprite_2d.animation = "jump"
	elif velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "walk"
	else:
		animated_sprite_2d.animation = "idle"


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
