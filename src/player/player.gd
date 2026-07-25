extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@onready var timerNode = $Timer


@export var speed = 300.0
@export var run_speed = 500.0
@export var jump_velocity = -500.0
@export var short_hop_divisor = 4.0
@export var attack_speed_scale = 1.5
@export var attack_1_active_frame = 2
@export var attack_2_active_frame = 3
@export var knockback_force: int = 1
@export var wall_jump_power = 500
@export var wall_jump_time = 0.2
@export var wall_slide_speed = 150.0
@export var double_jump_power = 350.0

var is_attacking = false
var is_running = false
var hit_box_was_active = false
var justWallJumped = false
var has_double_jumped = false
var has_5_coins = false

var is_knocked_back: bool = false

var key: bool = false
var coins: int = 0

func _ready() -> void:
	add_to_group("player")
	hit_box.monitorable = false
	EventBus.add_key.connect(_on_add_key)
	EventBus.use_key.connect(_on_use_key)
	EventBus.got_key.connect(_on_got_key)
	EventBus.add_coin.connect(_on_add_coin)
	EventBus.enemy_contact.connect(_on_enemy_contact)
	timerNode.connect('timeout', _on_timer_timeout)

func _on_timer_timeout() -> void:
	justWallJumped = false

func _on_add_key() -> void:
	key = true

func _on_add_coin() -> void:
	coins += 1
	has_5_coins = (coins >= 5)

func _on_use_key() -> void:
	key = false

func _on_got_key() -> void:
	if key:
		EventBus.one_key.emit()
	else:
		EventBus.no_key.emit()


func _on_enemy_contact(enemy_pos: Vector2) -> void:
	var knockback_clamped = clamp(knockback_force, 0, 10)
	velocity = (self.position - enemy_pos).normalized() * (500 * knockback_clamped)
	if is_on_floor():
		velocity.y = -(200 * knockback_clamped) 
	is_knocked_back = true
	await get_tree().create_timer(0.25).timeout
	is_knocked_back = false

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	is_running = Input.is_action_pressed("run") and direction != 0
 
	var current_speed = run_speed if is_running else speed

	if not justWallJumped and not is_knocked_back:
		velocity.x = direction * current_speed if direction else move_toward(velocity.x, 0, speed)

	if direction > 0 and not justWallJumped:
		animated_sprite_2d.flip_h = false
	elif direction < 0 and not justWallJumped:
		animated_sprite_2d.flip_h = true
	
	if Input.is_action_just_pressed("move_up") and not is_knocked_back:
		if is_on_floor():
			has_double_jumped = false 
			velocity.y = jump_velocity
		elif is_on_wall() and not has_5_coins:
				velocity.y = jump_velocity * 0.8
				velocity.x = get_wall_normal().x * wall_jump_power
				animated_sprite_2d.flip_h = get_wall_normal().x < 0
				justWallJumped = true
				timerNode.start(wall_jump_time)
		elif not has_double_jumped and has_5_coins:
			velocity.y = -double_jump_power
			has_double_jumped = true
	
	if (Input.is_action_just_released("move_up") and (not justWallJumped or not is_knocked_back)) and velocity.y < 0:
		velocity.y = jump_velocity / short_hop_divisor
	
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		velocity.y = min(velocity.y, wall_slide_speed)
	
	move_and_slide()
	
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
	elif is_running:
		animated_sprite_2d.animation = "run"
	elif velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "walk"
	else:
		animated_sprite_2d.animation = "idle"

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		hit_box.monitorable = false
		hit_box_was_active = false

func _on_animated_sprite_2d_frame_changed() -> void:
	if not is_attacking:
		return
 
	var anim = animated_sprite_2d.animation
	var frame = animated_sprite_2d.frame
 
	var is_active_frame = (anim == "attack_1" and frame == attack_1_active_frame) \
		or (anim == "attack_2" and frame == attack_2_active_frame)
 
	hit_box.monitorable = is_active_frame

	if is_active_frame and not hit_box_was_active:
		_apply_hit_to_existing_overlaps()
 
	hit_box_was_active = is_active_frame 
 
func _apply_hit_to_existing_overlaps() -> void:
	for area in hit_box.get_overlapping_areas():
		if area.name == "HitZone":
			area.get_parent().take_damage(hit_box.damage)
