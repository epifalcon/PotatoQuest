extends CanvasLayer

@onready var level_timer = $"../LevelTimer"

# Called when the node enters the scene tree for the first time.
func _ready():
	level_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
