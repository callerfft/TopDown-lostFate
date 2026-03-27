extends Camera2D
@onready var camera: Camera2D = $"."

@export var zoom_speed: float = 0.15
@export var min_zoom: float = 1
@export var max_zoom: float = 2.5

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(-zoom_speed)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(zoom_speed)
func _zoom(amount: float) -> void:
	var new_zoom := zoom.x + amount
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom = Vector2.ONE * new_zoom
