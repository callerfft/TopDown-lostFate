extends Control
#var ButtonPressed := false
@onready var pauseButton: Button = $"../pauseButton"
	#ButtonPressed = true #or ButtonPressed == true:
	#print(ButtonPressed)
func _ready() -> void:
	pauseButton.visible = true
	$AnimationPlayer.play("RESET")
	visible = false
	get_tree().paused = false
func pause():
	get_tree().paused = true
	visible = true
	$AnimationPlayer.play("blur")
func resume():
	get_tree().paused = false
	visible = false
	$AnimationPlayer.play_backwards("blur")
#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("esc"): 
func _on_button_pressed() -> void:
		if get_tree().paused:
			resume()
		else:
			pause()
			pauseButton.visible = false
func _on_continue_game_ui_pressed() -> void:
	pauseButton.visible = true
	resume()
func _on_restart_game_ui_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
func _on_lobby_game_ui_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/lobby.tscn")
