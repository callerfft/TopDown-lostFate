extends Control
 
func _ready() -> void:
	$"../AnimationPlayer".play("RESET")
	visible = false
	get_tree().paused = false
func pause():
	get_tree().paused = true
	visible = true
	$"../AnimationPlayer".play("blur")
func resume():
	get_tree().paused = false
	visible = false
	$"../AnimationPlayer".play_backwards("blur")
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()
func _on_button_pressed() -> void:
	resume()
func _on_button_2_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
func _on_button_3_pressed() -> void:
	get_tree().quit()
