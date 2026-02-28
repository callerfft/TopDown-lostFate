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
var shop_currency: int = 0

# Улучшения игрока
var upgrades = {
	"max_hp": 5,
	"current_hp": 5,
	"move_speed": 200,
	"damage_multiplier": 1.0,
	"attack_speed_multiplier": 1.0,
	
	# Способности
	"has_dash": false,
	"has_heal": false,
	"has_shield": false,
	
	# Постройки
	"turret_count": 0,
	"trap_count": 0,
	"wall_count": 0
}

# Купленные предметы из магазина
var purchased_items = {
	"double_shot": false,
	"triple_shot": false,
	"piercing_shot": false,
	"explosive_shot": false,
	"rapid_fire": false,
	"sword_range": false,
	"sword_speed": false,
	"scroll_fire": false,
	"scroll_ice": false,
	"scroll_lightning": false
}

# Путь к файлу сохранения
const SAVE_FILE = "user://savegame.save"

# Сигналы для UI
signal stats_updated
signal level_up(new_level)
signal currency_changed(amount)
signal item_purchased(item_id)

func _ready() -> void:
	load_game()
	emit_stats()

func emit_stats() -> void:
	stats_updated.emit()

# === СИСТЕМА ОПЫТА И УРОВНЕЙ ===

func add_exp(amount: int) -> void:
	current_exp += amount
	
	while current_exp >= exp_to_next_level:
		increase_level()
	
	emit_stats()

func increase_level() -> void:
	player_level += 1
	current_exp -= exp_to_next_level
	
	if player_level <= 10:
		exp_to_next_level = 100
	elif player_level <= 20:
		exp_to_next_level = 200
	else:
		exp_to_next_level = 300
	
	level_up.emit(player_level)

func add_kill() -> void:
	total_kills += 1
	kills_this_wave += 1
	add_exp(2)

# === СИСТЕМА ВОЛН ===

func next_wave() -> void:
	current_wave += 1
	kills_this_wave = 0
	emit_stats()

# === СИСТЕМА РЕСУРСОВ ===

func add_coins(amount: int) -> void:
	coins += amount
	emit_stats()

func add_artifacts(amount: int) -> void:
	artifacts += amount
	emit_stats()

func add_currency(amount: int) -> void:
	shop_currency += amount
	currency_changed.emit(shop_currency)
	emit_stats()

# === СИСТЕМА МАГАЗИНА ===

func can_afford(price: int) -> bool:
	return shop_currency >= price

func purchase_item(item_id: String, price: int) -> bool:
	if not can_afford(price):
		print("❌ Not enough currency!")
		return false
	
	if purchased_items.has(item_id) and purchased_items[item_id]:
		print("❌ Already purchased!")
		return false
	
	shop_currency -= price
	purchased_items[item_id] = true
	currency_changed.emit(shop_currency)
	item_purchased.emit(item_id)
	emit_stats()
	
	print("✅ Purchased: ", item_id)
	return true

# === СИСТЕМА УЛУЧШЕНИЙ ===

func apply_upgrade(upgrade_type: String) -> void:
	match upgrade_type:
		"increase_max_hp":
			upgrades.max_hp += 1
			upgrades.current_hp = upgrades.max_hp
		"increase_speed":
			upgrades.move_speed += 20
		"increase_damage":
			upgrades.damage_multiplier += 0.2
		"increase_attack_speed":
			upgrades.attack_speed_multiplier += 0.15
		"unlock_dash":
			upgrades.has_dash = true
		"unlock_heal":
			upgrades.has_heal = true
		"unlock_shield":
			upgrades.has_shield = true
		"build_turret":
			upgrades.turret_count += 1
		"build_trap":
			upgrades.trap_count += 1
		"build_wall":
			upgrades.wall_count += 1
	
	print("✅ Upgrade applied: ", upgrade_type)
	emit_stats()

# === СИСТЕМА СОХРАНЕНИЯ ===

func save_game() -> void:
	var save_data = {
		"player_level": player_level,
		"current_exp": current_exp,
		"exp_to_next_level": exp_to_next_level,
		"total_kills": total_kills,
		"current_wave": current_wave,
		"coins": coins,
		"artifacts": artifacts,
		"shop_currency": shop_currency,
		"upgrades": upgrades,
		"purchased_items": purchased_items
	}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("💾 Game saved!")
	else:
		print("❌ Failed to save game!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		print("📁 No save file found, starting new game")
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
		shop_currency = save_data.get("shop_currency", 0)
		upgrades = save_data.get("upgrades", upgrades)
		purchased_items = save_data.get("purchased_items", purchased_items)
		
		print("💾 Game loaded!")
	else:
		print("❌ Failed to load game!")

func reset_progress() -> void:
	player_level = 1
	current_exp = 0
	exp_to_next_level = 100
	total_kills = 0
	current_wave = 1
	kills_this_wave = 0
	coins = 0
	artifacts = 0
	shop_currency = 0
	
	upgrades = {
		"max_hp": 5,
		"current_hp": 5,
		"move_speed": 200,
		"damage_multiplier": 1.0,
		"attack_speed_multiplier": 1.0,
		"has_dash": false,
		"has_heal": false,
		"has_shield": false,
		"turret_count": 0,
		"trap_count": 0,
		"wall_count": 0
	}
	
	purchased_items = {
		"double_shot": false,
		"triple_shot": false,
		"piercing_shot": false,
		"explosive_shot": false,
		"rapid_fire": false,
		"sword_range": false,
		"sword_speed": false,
		"scroll_fire": false,
		"scroll_ice": false,
		"scroll_lightning": false
	}
	
	emit_stats()
	print("🔄 Progress reset!")

# === АВТОСОХРАНЕНИЕ ===

func start_autosave(interval: float = 40.0) -> void:
	var timer = Timer.new()
	timer.wait_time = interval
	timer.timeout.connect(save_game)
	add_child(timer)
	timer.start()
	print("💾 Autosave enabled (every ", interval, " seconds)")
