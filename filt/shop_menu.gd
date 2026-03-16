extends Control

@onready var currency_label: Label = $CurrencyLabel
@onready var close_button: Button = $CloseButton

# Предметы магазина
var shop_items = {
	"double_shot": {"name": "Double Shot", "price": 150},
	"triple_shot": {"name": "Triple Shot", "price": 300},
	"piercing_shot": {"name": "Piercing Bullets", "price": 200},
	"explosive_shot": {"name": "Explosive Bullets", "price": 250},
	"rapid_fire": {"name": "Rapid Fire", "price": 180},
	"sword_range": {"name": "Bigger Sword", "price": 100},
	"sword_speed": {"name": "Faster Sword", "price": 150},
	"scroll_fire": {"name": "🔥 Fire Scroll", "price": 200},
	"scroll_ice": {"name": "❄️ Ice Scroll", "price": 200},
	"scroll_lightning": {"name": "⚡ Lightning", "price": 250}
}

var item_buttons = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("shop_menu")
	
	# Подключаем сигналы
	GameManager.currency_changed.connect(_on_currency_changed)
	GameManager.item_purchased.connect(_on_item_purchased)
	
	if close_button:
		close_button.pressed.connect(hide_shop)
	
	# Создаем предметы вручную
	setup_items()
	
	visible = false

func setup_items() -> void:
	var items_container = get_node_or_null("ItemsContainer")
	if not items_container:
		print("❌ ItemsContainer not found!")
		return
	
	var index = 0
	for item_id in shop_items.keys():
		var item_data = shop_items[item_id]
		
		# Создаем строку товара
		var item_row = HBoxContainer.new()
		item_row.custom_minimum_size = Vector2(700, 50)
		
		# Название
		var name_label = Label.new()
		name_label.text = item_data.name
		name_label.custom_minimum_size = Vector2(300, 0)
		name_label.add_theme_font_size_override("font_size", 18)
		item_row.add_child(name_label)
		
		# Цена
		var price_label = Label.new()
		price_label.text = "💰 " + str(item_data.price)
		price_label.custom_minimum_size = Vector2(150, 0)
		price_label.add_theme_font_size_override("font_size", 18)
		item_row.add_child(price_label)
		
		# Кнопка
		var buy_button = Button.new()
		buy_button.text = "BUY"
		buy_button.custom_minimum_size = Vector2(150, 40)
		buy_button.pressed.connect(func(): purchase_item(item_id))
		item_row.add_child(buy_button)
		
		item_buttons[item_id] = buy_button
		items_container.add_child(item_row)
		
		index += 1

func show_shop() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	update_shop_ui()

func hide_shop() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_shop_ui() -> void:
	if currency_label:
		currency_label.text = "---Coins: %d" % GameManager.shop_currency
	
	# Обновляем кнопки
	for item_id in item_buttons.keys():
		var button = item_buttons[item_id]
		var item_data = shop_items[item_id]
		
		if GameManager.purchased_items.get(item_id, false):
			button.text = "OWNED"
			button.disabled = true
		elif not GameManager.can_afford(item_data.price):
			button.disabled = true
		else:
			button.text = "BUY"
			button.disabled = false

func purchase_item(item_id: String) -> void:
	var item_data = shop_items[item_id]
	
	if GameManager.purchase_item(item_id, item_data.price):
		print("Purchased: ", item_data.name)
		update_shop_ui()

func _on_currency_changed(_amount: int) -> void:
	if visible:
		update_shop_ui()

func _on_item_purchased(_item_id: String) -> void:
	if visible:
		update_shop_ui()
