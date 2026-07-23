extends Node2D

@onready var label: Label = $Label

@export var float_height: float = 80.0
@export var arc_amplitude: float = 30.0
@export var duration: float = 1.0
@export var positive_color: Color = Color.GREEN
@export var negative_color: Color = Color.RED
@export var min_rotation_range: float = -0.2
@export var max_rotation_range: float = 0.2

func start(amount: int) -> void:
	if amount > 0:
		label.text = "+%d" % amount
		label.modulate = positive_color
	else:
		label.text = "%d" % amount
		label.modulate = negative_color

	var tween = create_tween()

	var target_y = position.y + float_height
	tween.tween_property(self, "position:y", target_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var side = 1 if amount > 0 else -1

	var label_tween = create_tween()
	label_tween.tween_property(label, "position:x", label.position.x + (arc_amplitude * side), duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	label_tween.tween_property(label, "position:x", label.position.x, duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

	var target_rotation = randf_range(min_rotation_range, max_rotation_range)
	tween.parallel().tween_property(self, "rotation", target_rotation, duration).set_trans(Tween.TRANS_QUAD). set_ease(Tween.EASE_OUT)

	tween.chain().tween_callback(queue_free)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
