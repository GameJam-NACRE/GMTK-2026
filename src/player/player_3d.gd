extends CharacterBody3D

@onready var head: Node3D = $Head

@export_category("Déplacement")
@export var speed: float = 5.0
@export var run_speed: float = 8.0
@export var jump_velocity: float = 6.5 

@export_category("Caméra")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

var is_running: bool = false

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	var mouse_vel := Input.get_last_mouse_velocity()
	if mouse_vel != Vector2.ZERO:
		rotate_y(-mouse_vel.x * delta * (mouse_sensitivity * 0.1))
		
		head.rotate_x(-mouse_vel.y * delta * (mouse_sensitivity * 0.1))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	is_running = Input.is_action_pressed("run") and input_dir != Vector2.ZERO

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var current_speed = run_speed if is_running else speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
