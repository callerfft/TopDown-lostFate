extends Resource
class_name Item

# Basic item properties
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var stackable: bool = true
@export var max_stack: int = 99
@export var value: int = 0  # For trading later

func _init(p_id = "", p_name = "", p_description = "", p_icon = null, p_stackable = true, p_max_stack = 99, p_value = 0):
	id = p_id
	name = p_name
	description = p_description
	icon = p_icon
	stackable = p_stackable
	max_stack = p_max_stack
	value = p_value
