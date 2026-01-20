extends CanvasLayer
func _process(delta: float) -> void:
	$Label.text = str(int(Engine.get_frames_per_second())) + " fps"
	pass
