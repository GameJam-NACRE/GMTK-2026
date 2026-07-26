extends Level
class_name Level8

const CASE: float = 80.0
const TimeCollectibleScene = preload("res://scenes/items/time_collectible.tscn")

signal looping()

@export var point_a: Marker2D
@export var point_b: Marker2D
@export var point_c: Marker2D
@export var flag_distance: int = 5
@export var wall_speed: float = 200.0  # Vitesse du mur
@export var clock_frequency: float

@onready var player: CharacterBody2D = $Player
@onready var flag: FlagArea = $FlagArea
@onready var wall: AnimatableBody2D = $MovableWall
@onready var trigger_area: Area2D = $MovableWall/TriggerArea

# Les 3 états du mur
enum WallState { IDLE, RISING, LOOPING_X }
var current_state: WallState = WallState.IDLE

var distance_from_player: float
var start_x: float = 0.0
var target_y: float = 0.0
var target_x: float = 0.0

var player_tpd = false
var must_loop = true
var time_acc: float = 0

var numbers: Array = [2, 3, 4, 5, 6]

func _ready() -> void:
	super()
	EventBus.countdown_hud_mode.emit()
	looping.connect(_loop_dialogue)
	distance_from_player = flag_distance * CASE
	
	if not point_a or not point_b:
		push_error("Level8 : point_a ou point_b n'est pas assigné dans l'inspecteur !")
		
	start_x = wall.global_position.x
	
	trigger_area.body_entered.connect(_on_trigger_area_body_entered)

	EventBus.launch_dialogue.emit(0)
	await get_tree().create_timer(35).timeout
	must_loop = false
	looping.emit()
	

func add_time_collectible(pos: float, case: int, duration: int) -> void:
	var time_item = TimeCollectibleScene.instantiate()
	add_child(time_item)
	time_item.global_position.x = player.global_position.x + CASE * case
	time_item.global_position.y = pos

	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(time_item, "global_position", Vector2(time_item.global_position.x, 416), 0.2 * duration)

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == WallState.IDLE:

		target_y = wall.global_position.y - (2.5 * CASE)
		target_x = point_c.global_position.x 
		
		current_state = WallState.RISING

		EventBus.launch_dialogue.emit(1)

func _loop_dialogue() -> void:
	await get_tree().create_timer(35).timeout
	random_dialogue()
	_loop_dialogue()

func random_dialogue() -> void:
	# Mélange la liste aléatoirement
	numbers.shuffle()
	
	# Consomme la liste élément par élément
	if not numbers.is_empty():
		var chosen_number: int = numbers.pop_back() # Retire et renvoie le dernier nombre
		EventBus.launch_dialogue.emit(chosen_number)

func _physics_process(delta: float) -> void:
	match current_state:
		WallState.RISING:
			wall.global_position.y = move_toward(wall.global_position.y, target_y, wall_speed * delta * 3)
			
			if is_equal_approx(wall.global_position.y, target_y):
				current_state = WallState.LOOPING_X

		WallState.LOOPING_X:
			wall.global_position.x = move_toward(wall.global_position.x, target_x, wall_speed * delta)
			
			if is_equal_approx(wall.global_position.x, target_x):
				wall.global_position.x = start_x + 5 * CASE


	if not player or not flag or not point_a or not point_b or not point_c:
		return

	var p_x = player.global_position.x
	if must_loop:
		if player.velocity.x > 0 and p_x >= point_b.global_position.x:
			player.global_position.x = point_a.global_position.x
		elif player.velocity.x < 0 and p_x <= point_a.global_position.x:
			player.global_position.x = point_b.global_position.x
	else:
		if abs(player.global_position.x - point_c.global_position.x) < 5.0:
			player.global_position.x = point_a.global_position.x
			if p_x >= point_b.global_position.x:
				flag.global_position.x = point_a.global_position.x + distance_from_player
			player_tpd = true

		if abs(flag.global_position.x - player.global_position.x) <= distance_from_player:
			flag.global_position.x = player.global_position.x + distance_from_player

		time_acc += delta
		if (player_tpd):
			var time = randf_range(1 - clock_frequency, 2.5 - clock_frequency)
			if time_acc >= time:
				time_acc -= time
				add_time_collectible(randf_range(264, 416), randi_range(0, 1), randi_range(0, 5))
