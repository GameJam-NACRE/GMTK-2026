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
var has_sword = false

var is_knocked_back: bool = false

var key: bool = false
var coins: int = 0

# top down
@export_category("Top Down Game")
var is_top_down: bool = false
@export var lane_positions: Array[float] = [-160.0, 0.0, 160.0]
@export var lane_change_speed: float = 15.0
var current_lane: int = 1

func _ready() -> void:
	add_to_group("player")
	hit_box.monitorable = false
	EventBus.add_key.connect(_on_add_key)
	EventBus.add_sword.connect(_on_add_sword)
	EventBus.use_key.connect(_on_use_key)
	EventBus.got_key.connect(_on_got_key)
	EventBus.add_coin.connect(_on_add_coin)
	EventBus.enemy_contact.connect(_on_enemy_contact)
	timerNode.connect('timeout', _on_timer_timeout)

	EventBus.enable_top_down.connect(func(): is_top_down = true)

	enable_sword()

func level_has_sword(level: int) -> bool:
	if level in [0, 1, 2, 10, 11, 13, 14, 15]:
		return false
	return true

func enable_sword() -> void:
	print(GameManager.current_level)
	has_sword = level_has_sword(GameManager.current_level)

func _on_add_sword() -> void:
	has_sword = true

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
	if is_top_down:
		_process_top_down_physic(delta)
	else:
		_process_platformer_physic(delta)


func _process_top_down_physic(delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		if current_lane > 0:
			current_lane -= 1
			animated_sprite_2d.flip_h = true
	elif Input.is_action_just_pressed("move_right"):
		if current_lane < lane_positions.size() - 1:
			current_lane += 1
			animated_sprite_2d.flip_h = false

	var target_x: float = lane_positions[current_lane]

	global_position.x = lerp(global_position.x, target_x, lane_change_speed * delta)
	
	velocity.y = 0

	animated_sprite_2d.animation = "run"

	move_and_slide()


func _process_platformer_physic(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	is_running = Input.is_action_pressed("run") and direction != 0
 
	var current_speed = run_speed if is_running else speed

	if not justWallJumped and not is_knocked_back:
		velocity.x = direction * current_speed if direction else move_toward(velocity.x, 0, speed)

	if direction > 0 and not justWallJumped:
		animated_sprite_2d.flip_h = false
		hit_box.position.x = abs(hit_box.position.x)
	elif direction < 0 and not justWallJumped:
		animated_sprite_2d.flip_h = true
		hit_box.position.x = -abs(hit_box.position.x)
	
	if Input.is_action_just_pressed("move_up") and not is_knocked_back:
		if is_on_floor():
			has_double_jumped = false 
			velocity.y = jump_velocity
		elif is_on_wall() and not has_5_coins:
			velocity.y = jump_velocity * 0.8
			velocity.x = get_wall_normal().x * wall_jump_power
			animated_sprite_2d.flip_h = get_wall_normal().x < 0
			hit_box.position.x = abs(hit_box.position.x) * (-1 if get_wall_normal().x < 0 else 1)
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
	
	if Input.is_action_just_pressed("attack") and not is_attacking and has_sword:
		is_attacking = true
		if is_on_floor():
			animated_sprite_2d.play("attack_2", attack_speed_scale, false)
		else:
			animated_sprite_2d.play("attack_1", attack_speed_scale, false)
		return

	if is_attacking:
		return

	if not is_on_floor():
		if has_sword:
			animated_sprite_2d.animation = "jump"
		else:
			animated_sprite_2d.animation = "jump_no_sword"
	elif is_running:
		if has_sword:
			animated_sprite_2d.animation = "run"
		else:
			animated_sprite_2d.animation = "run_no_sword"
	elif velocity.x > 1 or velocity.x < -1:
		if has_sword:
			animated_sprite_2d.animation = "walk"
		else:
			animated_sprite_2d.animation = "walk_no_sword"
	else:
		if has_sword:
			animated_sprite_2d.animation = "idle"
		else:
			animated_sprite_2d.animation = "idle_no_sword"



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
