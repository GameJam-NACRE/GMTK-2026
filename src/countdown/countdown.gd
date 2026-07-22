extends CanvasLayer

@onready var label: Label = $PanelContainer/Label
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var time_left: float = timer.time_left

	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	var milliseconds: int = int((time_left - int(time_left)) * 100)

	label.text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]


func _on_timer_timeout() -> void:
	label.text = "00:00:00"
	print("Game Over")
