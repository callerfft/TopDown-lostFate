extends Area2D
class_name DroppedItem

@export var item_id: String = ""
@export var quantity: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var item: Item

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Get item from database
	var item_db = get_node("/root/ItemDatabase")
	if item_db:
		item = item_db.get_item(item_id)
		if item:
			if item.icon:
				sprite.texture = item.icon
			if quantity > 1:
				label.text = "x" + str(quantity)
			else:
				label.text = ""

func _on_body_entered(body):
	# Check if it's the player (adjust based on your player setup)
	if body.has_method("pick_up_item") or body.name == "Player":
		_pickup(body)

func _pickup(body):
	# Try to find inventory on player or in scene
	var inventory = null
	
	if body.has_node("Inventory"):
		inventory = body.get_node("Inventory")
	else:
		inventory = get_node_or_null("/root/Inventory")
	
	if inventory and item:
		if inventory.add_item(item, quantity):
			print("Picked up: ", item.name, " x", quantity)
			queue_free()
		else:
			print("Inventory full!")
