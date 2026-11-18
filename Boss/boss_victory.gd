extends ColorRect

func _input(event):
	if visible and event.is_action_pressed("ui_accept") and not event.is_echo():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://start_menu.tscn")
