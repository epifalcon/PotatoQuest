extends Area2D

signal health_changed(current_health: int, maximum_health: int)
signal boss_defeated

@export var sprout_scene: PackedScene
@export var maximum_health = 30
@export var move_speed = 70.0
@export var move_bounds = Vector2(560.0, 840.0)
@export var attack_interval = 1.4

var health = 30
var moving_right = true
var fight_active = false
var attack_time_left = 0.8

@onready var player: CharacterBody2D = get_node("../Player")
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	health = maximum_health
	health_changed.emit(health, maximum_health)

func _physics_process(delta):
	if not fight_active or health <= 0:
		return

	var direction = 1.0 if moving_right else -1.0
	position.x += direction * move_speed * delta
	if position.x >= move_bounds.y:
		position.x = move_bounds.y
		moving_right = false
	elif position.x <= move_bounds.x:
		position.x = move_bounds.x
		moving_right = true
	sprite.flip_h = not moving_right

	attack_time_left -= delta
	if attack_time_left <= 0.0:
		_throw_sprouted_potato()
		attack_time_left = attack_interval

func start_fight():
	fight_active = true

func take_hit():
	if health <= 0:
		return
	health -= 1
	health_changed.emit(health, maximum_health)
	if health == 0:
		boss_defeated.emit()

func _throw_sprouted_potato():
	var sprout = sprout_scene.instantiate()
	get_tree().current_scene.add_child(sprout)
	sprout.call("launch", global_position + Vector2(0.0, -72.0), player.global_position)
