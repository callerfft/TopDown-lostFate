extends Label

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	text = "FPS: " + str(fps)
	 
	if fps >= 55:
		modulate = Color(0, 1, 0)  # Зеленый - хорошо
	elif fps >= 30:
		modulate = Color(1, 1, 0)  # Желтый - средне
	else:
		modulate = Color(1, 0, 0)  # Красный - плохо
