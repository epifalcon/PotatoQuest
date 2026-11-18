extends Area2D

signal potato_captured

func _on_body_entered(body):
	potato_captured.emit()
	queue_free()
