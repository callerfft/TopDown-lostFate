extends Node

@export var orc_scene: PackedScene
#fdsgsgsgsgs
var enemies_alive: int = 0
var enemies_to_spawn: int = 0
var enemies_spawned_this_wave: int = 0
var is_wave_active: bool = false
var spawn_timer: Timer
var wave_timer: Timer
var can_skip_timer: bool = false

signal wave_started(wave_number)
signal wave_completed()
signal all_enemies_killed()

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 0.1 
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)
	
	start_wave()

func start_wave() -> void:
	is_wave_active = true
	can_skip_timer = false
	
	# Рассчитываем сколько врагов нужно заспавнить
	enemies_to_spawn = calculate_enemies_for_wave(GameManager.current_wave)
	enemies_spawned_this_wave = 0
	enemies_alive = 0
	
	print("=== WAVE ", GameManager.current_wave, " STARTED ===")
	print("Enemies to spawn: ", enemies_to_spawn)
	
	wave_started.emit(GameManager.current_wave)
	
	# Запускаем таймер спавна
	spawn_timer.start()

func calculate_enemies_for_wave(wave: int) -> int:
	if wave <= 20:
		return 13 + int((60 - 13) * (wave - 1) / 19.0)
	else:
		return 60

func _on_spawn_timer_timeout() -> void:
	if enemies_spawned_this_wave < enemies_to_spawn:
		spawn_enemy()
		enemies_spawned_this_wave += 1
		print("Spawned ", enemies_spawned_this_wave, " / ", enemies_to_spawn)
	else:
		# Все враги заспавнены - останавливаем таймер
		spawn_timer.stop()
		print("✅ All enemies spawned! Waiting for player to kill them all...")

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

func on_enemy_killed() -> void:
	if enemies_alive <= 0:
		print("⚠️ Warning: on_enemy_killed called but no enemies alive!")
		return
	
	enemies_alive -= 1
	GameManager.add_kill()
	
	print("💀 Enemy killed! Alive: ", enemies_alive, " / ", enemies_spawned_this_wave)
	
	# Проверяем - все враги убиты И все заспавнены?
	if enemies_alive <= 0 and enemies_spawned_this_wave >= enemies_to_spawn and is_wave_active:
		end_wave()

func end_wave() -> void:
	is_wave_active = false
	spawn_timer.stop()  # На всякий случай останавливаем
	
	print("🎉 WAVE ", GameManager.current_wave, " COMPLETED!")
	print("Starting 59 second timer...")
	
	wave_completed.emit()
	all_enemies_killed.emit()
	
	# Запускаем таймер до следующей волны
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
