extends Node
 

@onready var player = $AudioStreamPlayer

func _ready():
	if not player.playing:
		player.play()

func set_music_enabled(on: bool):
	player.stream_paused = !on
func play_music(stream):
	if player.stream == stream:
		return
	player.stream = stream
	player.play()
