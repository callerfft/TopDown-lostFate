extends Node
 
var player_level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 100
var total_kills: int = 0
 
var current_wave: int = 1
var kills_this_wave: int = 0
 
var coins: int = 0
var artifacts: int = 0
 
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

# Добавь после других переменных
var shop_currency: int = 0  # Специальная валюта для магазина

# Купленные предметы
var purchased_items = {
	"double_shot": false,
	"triple_shot": false,
	"piercing_shot": false,
	"explosive_shot": false,
	"sword_upgrade_1": false,
	"sword_upgrade_2": false,
	"scroll_fire": false,
	"scroll_ice": false,
	"scroll_lightning": false
}

signal currency_changed(amount)
signal item_purchased(item_id)

# Добавь функции
func add_currency(amount: int) -> void:
	shop_currency += amount
	currency_changed.emit(shop_currency)
	emit_stats()

func can_afford(price: int) -> bool:
	return shop_currency >= price

func purchase_item(item_id: String, price: int) -> bool:
	if not can_afford(price):
		return false
	
	if purchased_items.has(item_id) and purchased_items[item_id]:
		return false  # Уже куплено
	
	shop_currency -= price
	purchased_items[item_id] = true
	currency_changed.emit(shop_currency)
	item_purchased.emit(item_id)
	emit_stats()
	return true
const SAVE_FILE = "user://savegame.save"

signal stats_updated
signal level_up(new_level)
signal show_upgrade_menu  

func _ready() -> void:
	load_game()
	emit_stats()

func emit_stats() -> void:
	stats_updated.emit()

func add_exp(amount: int) -> void:
	current_exp += amount
	
	while current_exp >= exp_to_next_level:
		increase_level()
	
	emit_stats()

func increase_level() -> void:
	player_level += 1
	current_exp -= exp_to_next_level
	
	if player_level <= 10:
		exp_to_next_level = 10000
	elif player_level <= 20:
		exp_to_next_level = 200
	else:
		exp_to_next_level = 300
	
	level_up.emit(player_level)
	 
	show_upgrade_menu.emit()

func add_kill() -> void:
	total_kills += 1
	kills_this_wave += 1
	add_exp(20)

func next_wave() -> void:
	current_wave += 1
	kills_this_wave = 0
	emit_stats()

func add_coins(amount: int) -> void:
	coins += amount
	emit_stats()

func add_artifacts(amount: int) -> void:
	artifacts += amount
	emit_stats()
 
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

func save_game() -> void:
	var save_data = {
		"player_level": player_level,
		"current_exp": current_exp,
		"exp_to_next_level": exp_to_next_level,
		"total_kills": total_kills,
		"current_wave": current_wave,
		"coins": coins,
		"artifacts": artifacts,
		"upgrades": upgrades
	}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
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
		upgrades = save_data.get("upgrades", upgrades)

func reset_progress() -> void:
	player_level = 1
	current_exp = 0
	exp_to_next_level = 4
	total_kills = 0
	current_wave = 1
	kills_this_wave = 0
	coins = 0
	artifacts = 0
	upgrades = {
		"max_hp": 5,
		"current_hp": 5,
		"move_speed": 100,
		"damage_multiplier": 1.0,
		"attack_speed_multiplier": 1.0,
		"has_dash": false,
		"has_heal": false,
		"has_shield": false,
		"turret_count": 0,
		"trap_count": 0,
		"wall_count": 0
	}
	emit_stats()
