extends Area2D

var velocity = Vector2.ZERO
var lifetime = 6.0

func launch(start_position: Vector2, target_position: Vector2):
	global_position = start_position
	velocity = (target_position - start_position).normalized() * 190.0

func _physics_process(delta):
	velocity.y += 300.0 * delta
	global_position += velocity * delta
	rotation += 2.5 * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_hit"):
		body.call("take_hit")
	queue_free()
