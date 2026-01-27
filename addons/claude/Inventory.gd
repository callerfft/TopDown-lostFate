extends Node
class_name Inventory

signal inventory_changed

# Inventory storage: Array of dictionaries {item: Item, quantity: int}
var items: Array = []
@export var max_slots: int = 20  # Maximum inventory size

func add_item(item: Item, quantity: int = 1) -> bool:
	# If item is stackable, try to add to existing stack
	if item.stackable:
		for inv_item in items:
			if inv_item.item.id == item.id:
				var space_left = item.max_stack - inv_item.quantity
				if space_left > 0:
					var amount_to_add = min(quantity, space_left)
					inv_item.quantity += amount_to_add
					quantity -= amount_to_add
					inventory_changed.emit()
					
					if quantity == 0:
						return true
	
	# Create new stack(s)
	while quantity > 0:
		if items.size() >= max_slots:
			print("Inventory full!")
			return false
		
		var stack_size = min(quantity, item.max_stack if item.stackable else 1)
		items.append({
			"item": item,
			"quantity": stack_size
		})
		quantity -= stack_size
	
	inventory_changed.emit()
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	var remaining = quantity
	
	for i in range(items.size() - 1, -1, -1):
		if items[i].item.id == item_id:
			if items[i].quantity > remaining:
				items[i].quantity -= remaining
				inventory_changed.emit()
				return true
			else:
				remaining -= items[i].quantity
				items.remove_at(i)
				if remaining == 0:
					inventory_changed.emit()
					return true
	
	inventory_changed.emit()
	return remaining == 0

func has_item(item_id: String, quantity: int = 1) -> bool:
	var count = 0
	for inv_item in items:
		if inv_item.item.id == item_id:
			count += inv_item.quantity
	return count >= quantity

func get_item_count(item_id: String) -> int:
	var count = 0
	for inv_item in items:
		if inv_item.item.id == item_id:
			count += inv_item.quantity
	return count

func clear():
	items.clear()
	inventory_changed.emit()
