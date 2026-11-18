extends Node

signal timeout
@export var time_remaining = -1.0
var use_milliseconds = false
@onready var level_countdown = $LevelCountdown

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if time_remaining > 0:
		time_remaining -= delta
	elif time_remaining != -1.0:
		timeout.emit()
		reset_time()
		
	level_countdown.text = _format_seconds(time_remaining, use_milliseconds)


func _format_seconds(time : float, use_milliseconds : bool) -> String:
	if not use_milliseconds:
		return "%2d" % [time]
	else:
		var milliseconds = fmod(time, 1) * 100
		return "%2d:%02d" % [time, milliseconds]

func reset_time():
	time_remaining = -1.0
