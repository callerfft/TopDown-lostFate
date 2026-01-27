extends CharacterBody2D

@export var health: int = 100
@export var loot_table: LootTable

# Reference to dropped item scene
var dropped_item_scene = preload("res://DroppedItem.tscn")  # Create this scene!

func _ready():
	# Create a loot table if not assigned
	if not loot_table:
		loot_table = LootTable.create_common_enemy_loot()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	_drop_loot()
	queue_free()

func _drop_loot():
	var loot = loot_table.generate_loot()
	var item_db = get_node("/root/ItemDatabase")
	
	for loot_item in loot:
		# Spawn dropped item in world
		var dropped = dropped_item_scene.instantiate()
		dropped.item_id = loot_item.item_id
		dropped.quantity = loot_item.quantity
		dropped.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		
		get_parent().add_child(dropped)
