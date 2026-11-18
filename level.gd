extends Node2D

@export var next_level: PackedScene
@export var boss_level = false
var completed = false
var received_input = false
var potato_count = 0
var last_potato_count = 0
@onready var canvas_layer = $LevelCompletedCanvas
@onready var level_completed = $LevelCompletedCanvas/LevelCompleted
@onready var stopwatch = $UIElements/Stopwatch
@onready var player = $Player
@onready var potatoes_ui = $UIElements/Potatoes
@onready var health_ui: ProgressBar = $UIElements/Health
@onready var hurt_flash: ColorRect = $UIElements/HurtFlash
@onready var game_over = $UIElements/GameOver
var hurt_flash_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	potatoes_ui.text = "0"
	player.connect("hits_changed", Callable(self, "_on_player_hits_changed"))
	player.connect("player_died", Callable(self, "_on_player_died"))
	_on_player_hits_changed(player.get("hits_taken"), player.get("survivable_hits"))

func _process(delta):
	if not completed:
		var potatoes = get_tree().get_nodes_in_group("potatoes")

		if potatoes.size() < last_potato_count:
			var potatoes_collected = last_potato_count - potatoes.size()
			last_potato_count = potatoes.size()
			for _i in potatoes_collected:
				_on_potato_collect()
		elif potatoes.size() > last_potato_count:
			last_potato_count = potatoes.size()
			
		if potatoes.size() == 0 and not boss_level:
			print("Level completed")
			completed = true
			show_level_completed()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		received_input = true
		var level_path = ""
		match event.keycode:
			KEY_1, KEY_KP_1:
				level_path = "res://level_one.tscn"
			KEY_2, KEY_KP_2:
				level_path = "res://level_two.tscn"
			KEY_3, KEY_KP_3:
				level_path = "res://level_three.tscn"
			KEY_4, KEY_KP_4:
				level_path = "res://level_four.tscn"
		if not level_path.is_empty():
			get_tree().change_scene_to_file(level_path)

func show_level_completed():
	player.set_physics_process(false)
	stopwatch.paused = true
	level_completed.show()
	
	if next_level is PackedScene:
		level_completed.time_remaining = 3.0
		await level_completed.timeout
		level_completed.hide()
		stopwatch.time_elapsed = 0.0
		player.set_physics_process(true)
		get_tree().change_scene_to_packed(next_level)

func _on_potato_collect():
	potato_count += 1
	if boss_level:
		player.call("add_ammo")
		potatoes_ui.text = "Ammo: %d" % player.get("ammo")
	else:
		potatoes_ui.text = "%d" % potato_count

func _on_player_hits_changed(hits_taken: int, survivable_hits: int):
	health_ui.max_value = survivable_hits + 1
	health_ui.value = max(0, survivable_hits + 1 - hits_taken)
	_flash_hurt_screen()

func _flash_hurt_screen():
	if hurt_flash_tween and hurt_flash_tween.is_running():
		hurt_flash_tween.kill()
	hurt_flash.color.a = 0.45
	hurt_flash.show()
	hurt_flash_tween = create_tween()
	hurt_flash_tween.tween_property(hurt_flash, "color:a", 0.0, 0.25)
	hurt_flash_tween.tween_callback(hurt_flash.hide)

func _on_player_died():
	completed = true
	stopwatch.paused = true
	game_over.show()
	get_tree().paused = true
