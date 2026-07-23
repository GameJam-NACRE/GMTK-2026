extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func fade_out(duration: float = 1) -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP # Bloque l'input pendant la transition
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished
	EventBus.faded_to_black.emit()

func fade_in(duration: float = 1) -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	EventBus.fade_finished.emit()
