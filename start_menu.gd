extends CenterContainer

@onready var start_game_button = %StartGameButton

func _ready():
	start_game_button.grab_focus()

func _input(event):
	if not event is InputEventKey or not event.pressed or event.echo:
		return

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

func _on_start_game_button_pressed():
	get_tree().change_scene_to_file("res://level_one.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
