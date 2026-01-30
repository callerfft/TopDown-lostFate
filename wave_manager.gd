extends Node

@export var orc_scene: PackedScene

var enemies_alive: int = 0
var enemies_to_spawn: int = 13
var is_wave_active: bool = false
var spawn_timer: Timer
var wave_timer: Timer
var can_skip_timer: bool = false

signal wave_started(wave_number)
signal wave_completed()
signal all_enemies_killed()

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)
	
	enemies_to_spawn = calculate_enemies_for_wave(GameManager.current_wave)
	start_wave()

func start_wave() -> void:
	is_wave_active = true
	can_skip_timer = false
	enemies_to_spawn = calculate_enemies_for_wave(GameManager.current_wave)
	wave_started.emit(GameManager.current_wave)
	spawn_timer.start()

func calculate_enemies_for_wave(wave: int) -> int:
	if wave <= 20:
		return 13 + int((60 - 13) * (wave - 1) / 19.0)
	else:
		return 60

func _on_spawn_timer_timeout() -> void:
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
	else:
		spawn_timer.stop()
func spawn_enemy() -> void:
	if not orc_scene:
		push_error("Orc scene not assigned!")
		return
	
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if not player_node:
		return
	
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var random_distance = randf_range(500, 650)
	var spawn_pos = player_node.global_position + (random_direction * random_distance)
	
	var enemy = orc_scene.instantiate() as Node2D
	get_parent().add_child(enemy)
	enemy.global_position = spawn_pos
	
	enemies_alive += 1
	
	print("Enemy spawned at ", spawn_pos)
	
	# Подключаем сигнал с проверкой
	if not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)
		print("Signal enemy_died connected successfully")
	else:
		print("WARNING: Signal already connected!")
func _on_enemy_died() -> void:
	enemies_alive -= 1
	print("=== ENEMY DIED ===")
	print("Enemies alive: ", enemies_alive)
	print("Calling GameManager.add_kill()")
	
	GameManager.add_kill()
	
	print("Total kills now: ", GameManager.total_kills)
	print("==================")
	
	if enemies_alive <= 0 and enemies_to_spawn <= 0 and is_wave_active:
		end_wave()

func end_wave() -> void:
	is_wave_active = false
	wave_completed.emit()
	all_enemies_killed.emit()
	
	wave_timer.wait_time = 59.0
	wave_timer.start()
	can_skip_timer = true

func skip_wave_timer() -> void:
	if can_skip_timer and wave_timer.time_left > 0:
		wave_timer.stop()
		_on_wave_timer_timeout()

func _on_wave_timer_timeout() -> void:
	can_skip_timer = false
	GameManager.next_wave()
	start_wave()
