extends Node
class_name LootTable

# Array of loot entries: {item_id: String, chance: float (0-100), min_quantity: int, max_quantity: int}
@export var loot_entries: Array[Dictionary] = []

func add_loot(item_id: String, drop_chance: float, min_qty: int = 1, max_qty: int = 1):
	loot_entries.append({
		"item_id": item_id,
		"chance": drop_chance,
		"min_quantity": min_qty,
		"max_quantity": max_qty
	})

func generate_loot() -> Array:
	var dropped_items = []
	
	for entry in loot_entries:
		var roll = randf() * 100.0
		if roll <= entry.chance:
			var quantity = randi_range(entry.min_quantity, entry.max_quantity)
			dropped_items.append({
				"item_id": entry.item_id,
				"quantity": quantity
			})
	
	return dropped_items

# Example preset loot tables
static func create_common_enemy_loot() -> LootTable:
	var loot = LootTable.new()
	loot.add_loot("gold", 80.0, 1, 5)
	loot.add_loot("health_potion", 30.0, 1, 1)
	return loot

static func create_boss_loot() -> LootTable:
	var loot = LootTable.new()
	loot.add_loot("gold", 100.0, 50, 100)
	loot.add_loot("iron_sword", 50.0, 1, 1)
	loot.add_loot("health_potion", 75.0, 2, 5)
	loot.add_loot("mana_potion", 75.0, 2, 5)
	return loot

static func create_chest_loot() -> LootTable:
	var loot = LootTable.new()
	loot.add_loot("gold", 90.0, 10, 30)
	loot.add_loot("health_potion", 60.0, 1, 3)
	loot.add_loot("mana_potion", 40.0, 1, 2)
	return loot
