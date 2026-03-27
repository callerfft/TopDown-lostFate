extends Node
@onready var option: Panel = $UI/option
@onready var lobby_buttons: VBoxContainer = $UI/lobbyButtons
var check_button = false

func _ready() -> void:
	lobby_buttons.visible = true
	option.visible = false
	pass
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/environment/map.tscn")
func _on_option_button_pressed() -> void:
	print("option pressed")
	lobby_buttons.visible = false
	option.visible = true
	#get_tree().change_scene_to_file("res://menus/option_menus.tscn")
func _on_quit_button_pressed() -> void:
	get_tree().quit()
func _on_button_pressed() -> void:
	print("back pressed")
	lobby_buttons.visible = true
	option.visible = false



func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$AudioStreamPlayer.play()
		check_button = true
	else:
		$AudioStreamPlayer.stream_paused = true
		check_button = false
