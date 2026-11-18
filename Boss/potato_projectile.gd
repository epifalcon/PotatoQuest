extends Area2D

@export var speed = 420.0
var direction = 1.0

func launch(start_position: Vector2, shoot_direction: float):
	global_position = start_position
	direction = shoot_direction

func _physics_process(delta):
	global_position.x += speed * direction * delta

func _on_area_entered(area):
	if area.has_method("take_hit"):
		area.call("take_hit")
	queue_free()
