extends CharacterBody2D

signal ammo_changed(ammo_count: int)
signal hits_changed(hits_taken: int, survivable_hits: int)
signal player_died

@export var movement_data : PlayerMovementData
@export var has_potato_gun = false
@export var potato_projectile_scene: PackedScene
@export var survivable_hits = 3
@export var fall_respawn_time = 4.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_count = 0
var ammo = 0
var can_shoot_potatoes = false
var hits_taken = 0
var hit_cooldown = false
var is_dead = false
var fall_time = 0.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var potato_cannon = $PotatoCannon
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var hit_cooldown_timer = $HitCooldownTimer
@onready var starting_position = global_position

func _ready():
	potato_cannon.visible = has_potato_gun

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	handle_wall_jump()

	var direction = Input.get_axis("ui_left", "ui_right")
	
	handle_dash(direction)
	handle_shooting()
	apply_acceleration(direction, delta)
	apply_friction(direction, delta)
	update_animations(direction)
	var was_on_floor = is_on_floor()
	move_and_slide()
	update_fall_respawn(delta)
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
		
	# movement_data = load("res://FasterMovementData.tres")

func update_fall_respawn(delta):
	if is_on_floor() or velocity.y <= 0.0:
		fall_time = 0.0
		return

	fall_time += delta
	if fall_time >= fall_respawn_time:
		global_position = starting_position
		velocity = Vector2.ZERO
		fall_time = 0.0
		coyote_jump_timer.stop()

func add_ammo(amount: int = 1):
	ammo += amount
	ammo_changed.emit(ammo)

func take_hit():
	if hit_cooldown or is_dead:
		return

	hit_cooldown = true
	hit_cooldown_timer.start()
	hits_taken += 1
	hits_changed.emit(hits_taken, survivable_hits)
	if hits_taken <= survivable_hits:
		return

	is_dead = true
	set_physics_process(false)
	player_died.emit()

func handle_shooting():
	if not has_potato_gun or not can_shoot_potatoes or ammo <= 0 or potato_projectile_scene == null:
		return
	if not Input.is_action_just_pressed("shoot_potato"):
		return

	ammo -= 1
	ammo_changed.emit(ammo)
	var direction = -1.0 if animated_sprite_2d.flip_h else 1.0
	var projectile = potato_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.call("launch", global_position + Vector2(12.0 * direction, -14.0), direction)
	
func handle_dash(direction):
	if is_on_floor() and Input.is_action_just_pressed("dash") and abs(velocity.x) <= movement_data.speed:
		velocity.x = movement_data.dash_velocity * direction

func apply_acceleration(direction, delta):
	if direction:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.accel * delta)
		
func apply_friction(direction, delta):
	if direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
func handle_jump():
	if is_on_floor():
		jump_count = 0
		
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = movement_data.jump_velocity
			jump_count = 1
	elif not is_on_floor():
		if Input.is_action_just_released("ui_accept") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		
		if Input.is_action_just_pressed("ui_accept") and jump_count < movement_data.jump_max:
			velocity.y = movement_data.jump_velocity
			jump_count += 1
			
func handle_wall_jump():
	if not is_on_wall(): return
	
	var angle_tolerance = 10.0
	var wall_normal = get_wall_normal()
	var left_angle = abs(wall_normal.angle_to(Vector2.LEFT))
	var right_angle = abs(wall_normal.angle_to(Vector2.RIGHT))

	if Input.is_action_pressed("ui_left") and left_angle < angle_tolerance:
		velocity.y = velocity.y * 0.85
	if Input.is_action_pressed("ui_right") and right_angle < angle_tolerance:
		velocity.y = velocity.y * 0.85
	
	if Input.is_action_just_pressed("ui_accept") and left_angle < angle_tolerance:
		velocity.x = wall_normal.x * movement_data.speed * 1.1
		velocity.y = movement_data.jump_velocity
		jump_count = 1
	if Input.is_action_just_pressed("ui_accept") and right_angle < angle_tolerance:
		velocity.x = wall_normal.x * movement_data.speed * 1.1
		velocity.y = movement_data.jump_velocity
		jump_count = 1
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func update_animations(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	potato_cannon.flip_h = animated_sprite_2d.flip_h


func _on_hazard_detector_area_entered(area):
	take_hit()

func _on_hit_cooldown_timer_timeout():
	hit_cooldown = false
