extends Node

var music_player: AudioStreamPlayer
var current_track: String = ""

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = -8
	music_player.bus = "Music"
	
	# Автоматически зацикливаем
	music_player.finished.connect(func(): music_player.play())

func play_track(track_path: String, fade_in: bool = false) -> void:
	if current_track == track_path and music_player.playing:
		return
	
	current_track = track_path
	
	var music = load(track_path)
	if not music:
		print("❌ Music not found: ", track_path)
		return
	
	# ВАЖНО: Устанавливаем loop для AudioStream
	if music is AudioStreamOggVorbis:
		music.loop = true
	elif music is AudioStreamMP3:
		music.loop = true
	
	music_player.stream = music
	
	if fade_in:
		music_player.volume_db = -80
		music_player.play()
		fade_volume(-80, -8, 2.0)
	else:
		music_player.play()
func stop_music(fade_out: bool = false) -> void:
	if fade_out:
		fade_volume(music_player.volume_db, -80, 1.5)
		await get_tree().create_timer(1.5).timeout
	
	music_player.stop()
	current_track = ""

func fade_volume(from: float, to: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", to, duration).from(from)

func set_volume(volume_db: float) -> void:
	music_player.volume_db = volume_db

func pause_music() -> void:
	music_player.stream_paused = true

func resume_music() -> void:
	music_player.stream_paused = false
