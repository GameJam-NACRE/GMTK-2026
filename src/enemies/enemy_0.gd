class_name Enemy0 extends BaseEnemy

@export var point_a: Marker2D
@export var point_b: Marker2D
@export var move_speed: float = 100.0

var target: Marker2D
var moving_to_b: bool = true


func _ready() -> void:
	super()
	target = point_b

func _physics_process(delta: float) -> void:
	var direction_x = sign(target.global_position.x - global_position.x)
	velocity.x = direction_x * move_speed
	velocity.y += get_gravity().y * delta

	if abs(global_position.x - target.global_position.x) < 5.0:
		moving_to_b = not moving_to_b
		target = point_b if moving_to_b else point_a
	
	move_and_slide()
