extends Node2D
func _on_button_pressed() -> void:
	resume()
func _on_button_2_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
func _on_button_3_pressed() -> void:
	get_tree().quit()
