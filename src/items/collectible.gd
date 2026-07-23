@abstract
class_name Collectible extends Area2D

@onready var sprite = $CollectibleSprite2D
@onready var collision_shape = $CollisionShape2D

var is_collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_to_group("collectible")
	set_collision_shape()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if is_collected == true:
		return

	item_effect()
	queue_free()

func set_collision_shape() -> void:
	if not is_instance_valid(sprite) or not is_instance_valid(collision_shape):
		push_warning("Collectible: Sprite2D ou CollisionShape2D introuvable dans la scène.")
		return

	if not sprite.texture or not collision_shape.shape:
		return
	
	collision_shape.shape = collision_shape.shape.duplicate()

	var sprite_size = sprite.texture.get_size() * sprite.scale

	if collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = sprite_size
	elif collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = max(sprite_size.x, sprite_size.y) / 2
	else:
		push_warning("Collectible: type de Shape2D non géré (%s), collision non ajustée" % collision_shape.shape.get_class())



@abstract
func item_effect() -> void
