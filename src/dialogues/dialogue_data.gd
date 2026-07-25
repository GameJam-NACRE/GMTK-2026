class_name DialogueData extends Resource

@export var id: int = 0
@export_multiline var text: String = ""
@export var audio: AudioStream

@export var dial_char_speed: float = 0.05
@export var dial_long_pause: float = 0.4
@export var dial_short_pause: float = 0.25
@export var dial_time_if_audio: float = 2.0
@export var dial_time_if_no_audio: float = 4.0
