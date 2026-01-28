extends Node

# Статистика игрока
var player_level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 100
var total_kills: int = 0

# Прогресс игры
var current_wave: int = 1
var kills_this_wave: int = 0

# Собранные ресурсы
var coins: int = 0
var artifacts: int = 0

# Путь к файлу сохранения
const SAVE_FILE = "user://savegame.save"

# Сигналы для UI
signal exp_changed(current, needed)
signal level_up(new_level)
signal wave_changed(wave_number)
signal kills_changed(kills)
signal coins_changed(coins)
signal artifacts_changed(artifacts)

func _ready() -> void:
	load_game()
	
	# Испускаем все сигналы после загрузки, чтобы UI обновился
	await get_tree().process_frame  # Ждем один кадр, чтобы UI был готов
	emit_initial_signals()

# Добавь эту новую функцию
func emit_initial_signals() -> void:
	kills_changed.emit(total_kills)
	level_up.emit(player_level)
	exp_changed.emit(current_exp, exp_to_next_level)
	wave_changed.emit(current_wave)
	coins_changed.emit(coins)
	artifacts_changed.emit(artifacts)
# Добавить опыт
func add_exp(amount: int) -> void:
	current_exp += amount
	print("EXP added! Current: ", current_exp, " / ", exp_to_next_level)  # Добавь эту строку
	exp_changed.emit(current_exp, exp_to_next_level)
	
	# Проверка повышения уровня
	while current_exp >= exp_to_next_level:
		increase_level()
# Повышение уровня
func increase_level() -> void:
	player_level += 1
	current_exp -= exp_to_next_level
	
	# Расчет опыта для следующего уровня
	if player_level <= 10:
		exp_to_next_level = 100
	elif player_level <= 20:
		exp_to_next_level = 200
	else:
		exp_to_next_level = 300
	
	level_up.emit(player_level)
	exp_changed.emit(current_exp, exp_to_next_level)
func add_kill() -> void:
	total_kills += 1
	kills_this_wave += 1
	print("Kill added! Total: ", total_kills)  # Добавь эту строку
	kills_changed.emit(total_kills)
	
	# Добавляем опыт за убийство
	add_exp(2)
# Следующая волна
func next_wave() -> void:
	current_wave += 1
	kills_this_wave = 0
	wave_changed.emit(current_wave)

# Добавить монеты
func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

# Добавить артефакты
func add_artifacts(amount: int) -> void:
	artifacts += amount
	artifacts_changed.emit(artifacts)

# Сохранение игры
func save_game() -> void:
	var save_data = {
		"player_level": player_level,
		"current_exp": current_exp,
		"exp_to_next_level": exp_to_next_level,
		"total_kills": total_kills,
		"current_wave": current_wave,
		"coins": coins,
		"artifacts": artifacts
	}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved!")

# Загрузка игры
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found, starting new game")
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		player_level = save_data.get("player_level", 1)
		current_exp = save_data.get("current_exp", 0)
		exp_to_next_level = save_data.get("exp_to_next_level", 100)
		total_kills = save_data.get("total_kills", 0)
		current_wave = save_data.get("current_wave", 1)
		coins = save_data.get("coins", 0)
		artifacts = save_data.get("artifacts", 0)
		
		print("Game loaded!")

# Сброс прогресса (новая игра)
func reset_progress() -> void:
	player_level = 1
	current_exp = 0
	exp_to_next_level = 100
	total_kills = 0
	current_wave = 1
	kills_this_wave = 0
	coins = 0
	artifacts = 0
