extends Control

@onready var background: ColorRect = $background

@onready var side_panel: Panel = $SidePanel
@onready var upgrades_container: HBoxContainer = $SidePanel/UpgradesContainer
@onready var title_label: Label = $SidePanel/Title
@onready var close_button: Button = $SidePanel/CloseButton

# VBoxContainer карточек
@onready var card1_container: VBoxContainer = $SidePanel/UpgradesContainer/card1_button
@onready var card2_container: VBoxContainer = $SidePanel/UpgradesContainer/card2_button
@onready var card3_container: VBoxContainer = $SidePanel/UpgradesContainer/card3_button

# Label'ы внутри карточек
@onready var card1_name: Label = $SidePanel/UpgradesContainer/card1_button/Name
@onready var card1_desc: Label = $SidePanel/UpgradesContainer/card1_button/Description

@onready var card2_name: Label = $SidePanel/UpgradesContainer/card2_button/Name
@onready var card2_desc: Label = $SidePanel/UpgradesContainer/card2_button/Description

@onready var card3_name: Label = $SidePanel/UpgradesContainer/card3_button/Name
@onready var card3_desc: Label = $SidePanel/UpgradesContainer/card3_button/Description

var notification_button: Button
var pending_upgrades = []
var is_panel_open = false
var current_options = []

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
	},
	"build_turret": {
		"name": "Build Turret",
		"description": "Auto-shoots enemies (T)"
	},
	"build_trap": {
		"name": "Build Trap",
		"description": "Slows enemies 50% (Y)"
	},
	"build_wall": {
		"name": "Build Wall",
		"description": "Blocks enemies (U)"
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Подключаем сигналы
	GameManager.level_up.connect(_on_level_up)
	
	if close_button:
		close_button.pressed.connect(hide_panel)
	
	# Находим кнопку уведомления
	notification_button = get_parent().get_node_or_null("UpgradeNotification")
	if notification_button:
		notification_button.pressed.connect(show_panel)
		notification_button.visible = false
	
	# Скрываем панель за экраном
	if side_panel:
		side_panel.position.x = 1920
	
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") and pending_upgrades.size() > 0:
		if is_panel_open:
			hide_panel()
		else:
			show_panel()

func _on_level_up(new_level: int) -> void:
	var options = generate_random_upgrades()
	pending_upgrades.append(options)

	update_notification()

func generate_random_upgrades() -> Array:
	var available = all_upgrades.keys()
	
	if GameManager.upgrades.has_dash:
		available.erase("unlock_dash")
	if GameManager.upgrades.has_heal:
		available.erase("unlock_heal")
	if GameManager.upgrades.has_shield:
		available.erase("unlock_shield")
	
	available.shuffle()
	var selected = []
	for i in range(min(3, available.size())):
		selected.append(available[i])
	
	return selected
func show_panel() -> void:
	if pending_upgrades.is_empty():
		return
	
	is_panel_open = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Показываем затемнение
	if background:
		background.modulate.a = 0
		var bg_tween = create_tween()
		bg_tween.tween_property(background, "modulate:a", 1.0, 0.3)
	
	display_current_upgrades()
	
	# Анимация панели -нихуя не ИСПРАВЛЕНО
	var screen_width = get_viewport_rect().size.x
	var panel_width = 1140  # Фиксированная ширина панели
	
	var target_x = screen_width - panel_width
	
	var tween = create_tween()
	tween.tween_property(side_panel, "position:x", target_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	#print("Screen width: ", screen_width)
	#print("Panel target X: ", target_x)
func hide_panel() -> void:
	is_panel_open = false
	
	# Скрываем затемнение
	if background:
		var bg_tween = create_tween()
		bg_tween.tween_property(background, "modulate:a", 0.0, 0.2)
	
	# Анимация панели
	var tween = create_tween()
	tween.tween_property(side_panel, "position:x", 0, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

#____________________________________________________________________
func display_current_upgrades() -> void:
	if pending_upgrades.is_empty():
		return
	
	current_options = pending_upgrades[0]
	
	if title_label:
		title_label.text = "Choose Upgrade (%d available)" % pending_upgrades.size()
	
	# Обновляем карточки
	update_card(card1_container, card1_name, card1_desc, 0)
	update_card(card2_container, card2_name, card2_desc, 1)
	update_card(card3_container, card3_name, card3_desc, 2)

func update_card(container: VBoxContainer, name_label: Label, desc_label: Label, index: int) -> void:
	if not container:
		return
	
	if index >= current_options.size():
		container.visible = false
		return
	
	container.visible = true
	var upgrade_id = current_options[index]
	var upgrade_data = all_upgrades[upgrade_id]
	
	if name_label:
		name_label.text = upgrade_data.name
	if desc_label:
		desc_label.text = upgrade_data.description

func select_upgrade(index: int) -> void:
	if index >= current_options.size():
		return
	
	var upgrade_id = current_options[index]
	print("Selected: ", upgrade_id)
	
	GameManager.apply_upgrade(upgrade_id)
	
	if pending_upgrades.size() > 0:
		pending_upgrades.pop_front()
	
	update_notification()
	
	if pending_upgrades.size() > 0:
		display_current_upgrades()
	else:
		hide_panel()

func update_notification() -> void:
	if not notification_button:
		return
	
	if pending_upgrades.size() > 0:
		notification_button.text = "Upg:(%d)" % pending_upgrades.size()
		notification_button.visible = true
	else:
		notification_button.visible = false

# Обработчики кнопок
func _on_card1_button_pressed() -> void:
	select_upgrade(0)

func _on_card2_button_pressed() -> void:
	select_upgrade(1)

func _on_card3_button_pressed() -> void:
	select_upgrade(2)
