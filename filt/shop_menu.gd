extends Control

@onready var currency_label: Label = $Currency
@onready var close_button: Button = $CloseButton

# Предметы магазина
var shop_items = {
	"double_shot": {
		"name": "Double Shot",
		"description": "Fire 2 bullets at once",
		"price": 150,
		"category": "weapon"
	},
	"triple_shot": {
		"name": "Triple Shot",
		"description": "Fire 3 bullets in a spread",
		"price": 300,
		"category": "weapon"
	},
	"piercing_shot": {
		"name": "Piercing Bullets",
		"description": "Bullets go through enemies",
		"price": 200,
		"category": "weapon"
	},
	"explosive_shot": {
		"name": "Explosive Bullets",
		"description": "Bullets explode on impact",
		"price": 250,
		"category": "weapon"
	},
	"sword_upgrade_1": {
		"name": "Bigger Sword",
		"description": "+50% sword range",
		"price": 100,
		"category": "melee"
	},
	"sword_upgrade_2": {
		"name": "Faster Sword",
		"description": "+50% sword speed",
		"price": 150,
		"category": "melee"
	},
	"scroll_fire": {
		"name": "🔥 Fire Scroll",
		"description": "Burn enemies over time",
		"price": 200,
		"category": "scroll"
	},
	"scroll_ice": {
		"name": "❄️ Ice Scroll",
		"description": "Freeze enemies temporarily",
		"price": 200,
		"category": "scroll"
	},
	"scroll_lightning": {
		"name": "⚡ Lightning Scroll",
		"description": "Chain lightning between enemies",
		"price": 250,
		"category": "scroll"
	}
}

var wave_manager: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Подключаем сигналы
	GameManager.currency_changed.connect(_on_currency_changed)
	
	# Находим WaveManager
	wave_manager = get_tree().get_first_node_in_group("wave_manager")
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)
	
	# Подключаем кнопку закрытия
	close_button.pressed.connect(hide_shop)
	
	# Подключаем кнопки покупки (нужно сделать для каждого предмета)
	connect_buy_buttons()
	
	# Инициализируем предметы
	setup_shop_items()
	
	visible = false

func _input(event: InputEvent) -> void:
	# Закрытие по ESC
	if event.is_action_pressed("ui_cancel") and visible:
		hide_shop()

func connect_buy_buttons() -> void:
	# Подключаем все кнопки BUY
	var items = ["ShopItem1", "ShopItem2", "ShopItem3", "ShopItem4", 
				 "ShopItem5", "ShopItem6", "ShopItem7", "ShopItem8", "ShopItem9"]
	
	var item_ids = shop_items.keys()
	
	for i in range(items.size()):
		var item_path = "ItemsContainer/ItemsGrid/" + items[i] + "/BuyButton"
		if has_node(item_path):
			var button = get_node(item_path)
			var item_id = item_ids[i] if i < item_ids.size() else ""
			button.pressed.connect(func(): purchase_item(item_id))

func setup_shop_items() -> void:
	# Заполняем информацию о предметах
	var items = ["ShopItem1", "ShopItem2", "ShopItem3", "ShopItem4", 
				 "ShopItem5", "ShopItem6", "ShopItem7", "ShopItem8", "ShopItem9"]
	
	var item_ids = shop_items.keys()
	
	for i in range(items.size()):
		if i >= item_ids.size():
			break
		
		var item_id = item_ids[i]
		var item_data = shop_items[item_id]
		var base_path = "ItemsContainer/ItemsGrid/" + items[i]
		
		# Устанавливаем название
		if has_node(base_path + "/NameLabel"):
			get_node(base_path + "/NameLabel").text = item_data.name
		
		# Описание
		if has_node(base_path + "/DescriptionLabel"):
			get_node(base_path + "/DescriptionLabel").text = item_data.description
		
		# Цена
		if has_node(base_path + "/PriceLabel"):
			get_node(base_path + "/PriceLabel").text = "💰 " + str(item_data.price)

func show_shop() -> void:
	visible = true
	update_shop_ui()
	print("🛒 Shop opened!")

func hide_shop() -> void:
	visible = false
	print("🛒 Shop closed")

func update_shop_ui() -> void:
	# Обновляем валюту
	currency_label.text = "💰 Coins: %d" % GameManager.shop_currency
	
	# Обновляем кнопки (недоступно если уже куплено или не хватает денег)
	var items = ["ShopItem1", "ShopItem2", "ShopItem3", "ShopItem4", 
				 "ShopItem5", "ShopItem6", "ShopItem7", "ShopItem8", "ShopItem9"]
	
	var item_ids = shop_items.keys()
	
	for i in range(items.size()):
		if i >= item_ids.size():
			break
		
		var item_id = item_ids[i]
		var item_data = shop_items[item_id]
		var button_path = "ItemsContainer/ItemsGrid/" + items[i] + "/BuyButton"
		
		if has_node(button_path):
			var button = get_node(button_path)
			
			# Уже куплено?
			if GameManager.purchased_items.get(item_id, false):
				button.text = "OWNED"
				button.disabled = true
			# Не хватает денег?
			elif not GameManager.can_afford(item_data.price):
				button.text = "BUY"
				button.disabled = true
			else:
				button.text = "BUY"
				button.disabled = false

func purchase_item(item_id: String) -> void:
	if not shop_items.has(item_id):
		return
	
	var item_data = shop_items[item_id]
	
	if GameManager.purchase_item(item_id, item_data.price):
		print("✅ Purchased: ", item_data.name)
		update_shop_ui()
	else:
		print("❌ Cannot purchase: ", item_data.name)

func _on_currency_changed(amount: int) -> void:
	if visible:
		update_shop_ui()

func _on_wave_started(_wave_number: int) -> void:
	# Закрываем магазин когда волна начинается
	hide_shop()

func _on_wave_completed() -> void:
	# Даем валюту за завершение волны
	var reward = 50 + (GameManager.current_wave * 10)
	GameManager.add_currency(reward)
	
	# Открываем магазин
	await get_tree().create_timer(1.0).timeout
	show_shop()
