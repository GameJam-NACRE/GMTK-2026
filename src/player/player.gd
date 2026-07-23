extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@onready var sprite = $Sprite2D

@export var idle_texture: Texture2D
@export var walk_texture: Texture2D
@export var jump_texture: Texture2D

var screen_size

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_velocity 

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed 
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif direction != 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.flip_h = direction < 0
