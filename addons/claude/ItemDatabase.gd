extends Node

# Dictionary to store all items by ID
var items: Dictionary = {}

func _ready():
	_load_items()

func _load_items():
	# Add your items here - example items below
	
	# Health Potion
	var health_potion = Item.new(
		"health_potion",
		"Health Potion",
		"Restores 50 HP",
		null,  # Add icon texture here later
		true,
		99,
		10
	)
	items["health_potion"] = health_potion
	
	# Mana Potion
	var mana_potion = Item.new(
		"mana_potion",
		"Mana Potion",
		"Restores 30 MP",
		null,
		true,
		99,
		8
	)
	items["mana_potion"] = mana_potion
	
	# Sword
	var sword = Item.new(
		"iron_sword",
		"Iron Sword",
		"A sturdy iron sword",
		null,
		false,  # Weapons don't stack
		1,
		50
	)
	items["iron_sword"] = sword
	
	# Gold Coin
	var gold = Item.new(
		"gold",
		"Gold Coin",
		"Currency for trading",
		null,
		true,
		999,
		1
	)
	items["gold"] = gold

func get_item(item_id: String) -> Item:
	if items.has(item_id):
		return items[item_id]
	return null
