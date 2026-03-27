extends Control
@onready var death_screen: Control = $"."
#func pause():
	#get_tree().paused = true
	#visible = true

func resume():
	death_screen.visible = false
	get_tree().paused = false
func _on_restart_button_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/environment/map.tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/lobby.tscn")
	
#get_tree().paused = false
func set_highest_time(value):
	$"Panel/highest time".text = "score: " + str(value)

func set_score(value):
	$Panel/score .text = "score: " + str(value)
	
