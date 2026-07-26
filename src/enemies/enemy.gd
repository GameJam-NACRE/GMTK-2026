@abstract
class_name BaseEnemy extends CharacterBody2D

signal died()
signal health_changed(current: int, max: int)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hit_zone = $HitZone

@export var max_health: int = 1
var current_health: int
var is_dead: bool = false

func _ready() -> void:
	current_health = max_health
	self.add_to_group("enemy")

	hit_zone.body_entered.connect(_on_body_entered)
	hit_zone.area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	EventBus.enemy_contact.emit(self.global_position)

func _on_area_entered(area: Area2D) -> void:
	print("Bob meurt")
	if is_dead:
		return
	var hit_box := area as HitBox
	if hit_box == null:
		return
	
	take_damage(hit_box.damage)

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	
	current_health -= amount
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		is_dead = true
		die()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func die() -> void:
	died.emit()
	EventBus.add_time.emit(5)
	is_dead = true
	set_deferred("disabled", true)
	animated_sprite_2d.animation = "die"
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.stop()
	self.queue_free()
