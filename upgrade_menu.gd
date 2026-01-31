extends Control

# Карточки улучшений
@onready var card1: VBoxContainer = $UpgradesContainer/UpgradeCard1
@onready var card2: VBoxContainer = $UpgradesContainer/UpgradeCard2
@onready var card3: VBoxContainer = $UpgradesContainer/UpgradeCard3

# Элементы карточки 1
@onready var card1_name: Label = $UpgradesContainer/UpgradeCard2/Name
@onready var card1_desc: Label = $UpgradesContainer/UpgradeCard2/Description
@onready var card1_btn: Button = $UpgradesContainer/UpgradeCard1/SelectButton

# Элементы карточки 2
@onready var card2_name: Label = $UpgradesContainer/UpgradeCard2/Name
@onready var card2_desc: Label = $UpgradesContainer/UpgradeCard2/Description
@onready var card2_btn: Button = $UpgradesContainer/UpgradeCard2/SelectButton

# Элементы карточки 3
@onready var card3_name: Label = $UpgradesContainer/UpgradeCard3/Name
@onready var card3_desc: Label = $UpgradesContainer/UpgradeCard3/Description
@onready var card3_btn: Button = $UpgradesContainer/UpgradeCard3/SelectButton

# Доступные улучшения
var all_upgrades = {
	"increase_max_hp": {
		"name": "+1 Max HP",
		"description": "Increase maximum health by 1"
	},
	"increase_speed": {
		"name": "+20% Speed",
		"description": "Move 20% faster"
	},
	"increase_damage": {
		"name": "+20% Damage",
		"description": "Deal 20% more damage"
	},
	"increase_attack_speed": {
		"name": "+15% Attack Speed",
		"description": "Attack 15% faster"
	},
	"unlock_dash": {
		"name": "Unlock Dash",
		"description": "Press Shift to dash forward"
	},
	"unlock_heal": {
		"name": "Unlock Heal",
		"description": "Press H to heal 2 HP (cooldown 30s)"
	},
	"unlock_shield": {
		"name": "Unlock Shield",
		"description": "Press G to block damage for 3s"
	},
	"build_turret": {
		"name": "Build Turret",
		"description": "Place a turret that shoots enemies"
	},
	"build_trap": {
		"name": "Build Trap",
		"description": "Place a trap that slows enemies"
	},
	"build_wall": {
		"name": "Build Wall",
		"description": "Place a wall that blocks enemies"
	}
}

var current_options = []

func _ready() -> void:
	# Подключаемся к сигналу level up
	GameManager.level_up.connect(_on_level_up)
	
	# Подключаем кнопки
	card1_btn.pressed.connect(func(): select_upgrade(0))
	card2_btn.pressed.connect(func(): select_upgrade(1))
	card3_btn.pressed.connect(func(): select_upgrade(2))
	
	# Скрываем меню
	visible = false

func _on_level_up(_new_level: int) -> void:
	show_menu()

func show_menu() -> void:
	# Останавливаем игру
	get_tree().paused = true
	
	# Генерируем 3 случайных улучшения
	generate_random_upgrades()
	
	# Показываем меню
	visible = true

func generate_random_upgrades() -> void:
	current_options = []
	var available_upgrades = all_upgrades.keys()
	
	# Убираем уже разблокированные способности
	if GameManager.upgrades.has_dash:
		available_upgrades.erase("unlock_dash")
	if GameManager.upgrades.has_heal:
		available_upgrades.erase("unlock_heal")
	if GameManager.upgrades.has_shield:
		available_upgrades.erase("unlock_shield")
	
	# Выбираем 3 случайных улучшения
	available_upgrades.shuffle()
	for i in range(min(3, available_upgrades.size())):
		current_options.append(available_upgrades[i])
	
	# Заполняем карточки
	update_card(0, card1_name, card1_desc)
	update_card(1, card2_name, card2_desc)
	update_card(2, card3_name, card3_desc)

func update_card(index: int, name_label: Label, desc_label: Label) -> void:
	if index >= current_options.size():
		return
	
	var upgrade_id = current_options[index]
	var upgrade_data = all_upgrades[upgrade_id]
	
	name_label.text = upgrade_data.name
	desc_label.text = upgrade_data.description

func select_upgrade(index: int) -> void:
	if index >= current_options.size():
		return
	
	var selected_upgrade = current_options[index]
	
	print("🎁 Selected upgrade: ", selected_upgrade)
	
	# Применяем улучшение
	GameManager.apply_upgrade(selected_upgrade)
	
	# Скрываем меню
	hide_menu()

func hide_menu() -> void:
	visible = false
	
	# Возобновляем игру
	get_tree().paused = false
