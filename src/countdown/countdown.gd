extends CanvasLayer

@onready var label: Label = $PanelContainer/Label
@onready var countdown: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown.timeout.connect(_on_countdown_timeout)
	EventBus.add_time.connect(_on_add_time)
	EventBus.remove_time.connect(_on_remove_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var time_left: float = countdown.time_left

	var minutes: int = int(time_left) / 60
	var seconds: int = int(time_left) % 60
	var milliseconds: int = int((time_left - int(time_left)) * 100)

	label.text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func _on_countdown_timeout() -> void:
	label.text = "00:00:00"
	EventBus.countdown_end.emit()
	print("Game Over")

func _on_add_time(sec: int) -> void:
	if countdown.is_stopped():
		return

	var new_time = countdown.time_left + sec
	countdown.start(new_time)

func _on_remove_time(sec: int) -> void:
	if countdown.is_stopped():
		return

	var new_time = countdown.time_left - sec

	if new_time <= 0.0 :
		countdown.stop()
		_on_countdown_timeout()
	else :
		countdown.start(new_time)
