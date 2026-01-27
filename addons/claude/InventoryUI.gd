extends Control

# Убери @onready для autoload нодов
var inventory: Inventory
var item_db

@onready var item_list: ItemList = $CanvasLayer/Panel/ItemList
@onready var item_info: Label = $CanvasLayer/Panel/ItemInfo

func _ready():
	# Получаем autoload ноды
	inventory = get_node("/root/Inventory")
	item_db = get_node("/root/ItemDatabase")
	
	# Тестовое добавление предмета (можешь удалить позже)
	var potion = item_db.get_item("health_potion")
	if potion:
		inventory.add_item(potion, 3)
	
	# Подключаем сигналы
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		_update_display()
	
	item_list.item_selected.connect(_on_item_selected)

func _update_display():
	item_list.clear()
	
	for inv_item in inventory.items:
		var item = inv_item.item
		var quantity = inv_item.quantity
		
		var display_text = item.name
		if item.stackable and quantity > 1:
			display_text += " x" + str(quantity)
		
		item_list.add_item(display_text, item.icon)

func _on_inventory_changed():
	_update_display()

func _on_item_selected(index: int):
	if index < 0 or index >= inventory.items.size():
		return
	
	var inv_item = inventory.items[index]
	var item = inv_item.item
	
	var info_text = "[b]%s[/b]\n\n%s\n\nValue: %d gold" % [
		item.name,
		item.description,
		item.value
	]
	
	if item.stackable:
		info_text += "\nQuantity: %d" % inv_item.quantity
	
	item_info.text = info_text

func _input(event):
	# Открыть/закрыть инвентарь клавишей Tab
	if event.is_action_pressed("inventory"):  # ESC или Tab
		visible = !visible
