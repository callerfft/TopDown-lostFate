extends Control

# Элементы карточки 1
@onready var card1_name: Label = $UpgradesContainer/card1_button/Name
@onready var card1_desc: Label = $UpgradesContainer/card1_button/Description

# Элементы карточки 2
@onready var card2_name: Label = $UpgradesContainer/card2_button/Name
@onready var card2_desc: Label = $UpgradesContainer/card2_button/Description

# Элементы карточки 3
@onready var card3_name: Label = $UpgradesContainer/card3_button/Name
@onready var card3_desc: Label = $UpgradesContainer/card3_button/Description

# Доступные улучшения
var all_upgrades = {
	"increase_max_hp": {
		"name": "+1 Max HP",
		"description": "Increase maximum health by 1"
	},
	"increase_speed": {
		"name": "+20 Speed",
		"description": "Move faster"
	},
	"increase_damage": {
		"name": "+20% Damage",
		"description": "Deal more damage"
	},
	"unlock_dash": {
		"name": "Unlock Dash",
		"description": "Press Shift to dash"
	},
	"unlock_heal": {
		"name": "Unlock Heal",
		"description": "Press H to heal 2 HP"
	},
	"unlock_shield": {
		"name": "Unlock Shield",
		"description": "Press G for shield"
	}
}

var current_options = []

func _ready() -> void:
	# Подключаемся к level up
	GameManager.level_up.connect(_on_level_up)
	
	# Скрываем меню
	visible = false

func _on_level_up(new_level: int) -> void:
	print("🎉 LEVEL UP! Level: ", new_level)
	show_menu()

func show_menu() -> void:
	# Останавливаем игру
	get_tree().paused = true
	
	# Генерируем улучшения
	generate_random_upgrades()
	
	# Показываем меню
	visible = true

func generate_random_upgrades() -> void:
	current_options = []
	var available = all_upgrades.keys()
	
	# Убираем уже разблокированные
	if GameManager.upgrades.has_dash:
		available.erase("unlock_dash")
	if GameManager.upgrades.has_heal:
		available.erase("unlock_heal")
	if GameManager.upgrades.has_shield:
		available.erase("unlock_shield")
	
	# Выбираем 3 случайных
	available.shuffle()
	for i in range(min(3, available.size())):
		current_options.append(available[i])
	
	# Обновляем карточки
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

# === ЭТИ ФУНКЦИИ СОЗДАЛИСЬ АВТОМАТИЧЕСКИ ПРИ ПОДКЛЮЧЕНИИ КНОПОК ===
func _on_card1_button_pressed() -> void:
	select_upgrade(0)

func _on_card2_button_pressed() -> void:
	select_upgrade(1)

func _on_card3_button_pressed() -> void:
	select_upgrade(2)
	print("hui")
func select_upgrade(index: int) -> void:
	if index >= current_options.size():
		return
	
	var selected = current_options[index]
	print("✅ Selected: ", selected)
	
	# Применяем улучшение
	GameManager.apply_upgrade(selected)
	
	# Скрываем меню
	hide_menu()

func hide_menu() -> void:
	visible = false
	get_tree().paused = false
