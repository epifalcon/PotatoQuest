extends "res://level.gd"

const POTATO_PICKUP_SCENE = preload("res://Collectibles/potato.tscn")
const MAX_AMMO_PICKUPS = 5
const AMMO_SPAWN_POINTS = [
	Vector2(80, 275), Vector2(180, 275), Vector2(280, 275),
	Vector2(380, 275), Vector2(480, 275), Vector2(580, 275),
	Vector2(680, 275), Vector2(780, 275), Vector2(880, 275),
	Vector2(350, 195), Vector2(420, 195), Vector2(490, 195),
	Vector2(770, 195), Vector2(840, 195), Vector2(910, 195),
	Vector2(590, 155), Vector2(650, 155), Vector2(710, 155)
]

@onready var boss: Node2D = $Boss
@onready var boss_intro: Control = $UIElements/BossIntro
@onready var boss_health: ProgressBar = $UIElements/BossHealth
@onready var boss_health_label: Label = $UIElements/BossHealthLabel
@onready var boss_victory: Control = $UIElements/BossVictory
@onready var potato_pickups: Node2D = $Potatoes

var intro_started = false
var player_start_position: Vector2

func _ready():
	super._ready()
	player_start_position = player.global_position
	player.connect("ammo_changed", Callable(self, "_on_ammo_changed"))
	player.call("add_ammo", 5)
	boss.connect("health_changed", Callable(self, "_on_boss_health_changed"))
	boss.connect("boss_defeated", Callable(self, "_on_boss_defeated"))
	boss_health.max_value = boss.get("maximum_health")
	_on_boss_health_changed(boss.get("health"), boss.get("maximum_health"))

	var ammo_spawn_timer = Timer.new()
	ammo_spawn_timer.wait_time = 2.0
	ammo_spawn_timer.timeout.connect(_spawn_ammo_pickup)
	add_child(ammo_spawn_timer)
	ammo_spawn_timer.start()

func _process(delta):
	super._process(delta)
	if intro_started or completed:
		return

	var direction_to_boss = (boss.global_position - player_start_position).normalized()
	var distance_toward_boss = (player.global_position - player_start_position).dot(direction_to_boss)
	if distance_toward_boss >= 12.0:
		_show_boss_intro()

func _input(event):
	if completed and event.is_action_pressed("ui_accept") and not event.is_echo():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://start_menu.tscn")

func _show_boss_intro():
	intro_started = true
	boss_intro.show()
	get_tree().paused = true
	await get_tree().create_timer(2.0, true).timeout
	if not is_inside_tree():
		return
	get_tree().paused = false
	boss_intro.hide()
	boss.call("start_fight")
	player.set("can_shoot_potatoes", true)

func _on_ammo_changed(ammo_count: int):
	potatoes_ui.text = "Ammo: %d" % ammo_count

func _spawn_ammo_pickup():
	if get_tree().get_nodes_in_group("potatoes").size() >= MAX_AMMO_PICKUPS:
		return

	var available_points = []
	for point in AMMO_SPAWN_POINTS:
		var point_is_clear = true
		for pickup in potato_pickups.get_children():
			if not pickup.is_queued_for_deletion() and pickup.position.distance_to(point) < 40.0:
				point_is_clear = false
				break
		if point_is_clear:
			available_points.append(point)

	if available_points.is_empty():
		return

	var pickup = POTATO_PICKUP_SCENE.instantiate()
	potato_pickups.add_child(pickup)
	pickup.position = available_points.pick_random()

func _on_boss_health_changed(current_health: int, maximum_health: int):
	boss_health.max_value = maximum_health
	boss_health.value = current_health
	boss_health_label.text = "POTATO KING  %d / %d" % [current_health, maximum_health]

func _on_boss_defeated():
	completed = true
	player.set_physics_process(false)
	stopwatch.paused = true
	boss_victory.show()
	get_tree().paused = true

func _exit_tree():
	if get_tree().paused:
		get_tree().paused = false
