extends Node2D

@onready var trigger_box = $Area2D
@onready var arrow = $Sprite2D


func _ready() -> void:
	trigger_box.body_entered.connect(_on_trigger_body_entered)

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name.to_lower().begins_with("player"):
		arrow.visible = true
