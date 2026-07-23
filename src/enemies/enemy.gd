@abstract
class_name BaseEnemy extends CharacterBody2D

signal died()
signal health_changed(current: int, max: int)

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hit_zone = $HitZone

@export var max_health: int = 1
var current_health: int

func _ready() -> void:
	current_health = max_health
	self.add_to_group("enemy")

	hit_zone.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	EventBus.enemy_contact.emit(self.global_position)

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	
	current_health -= amount
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func die() -> void:
	died.emit()
	self.queue_free()
