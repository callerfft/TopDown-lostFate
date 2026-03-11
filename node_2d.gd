extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play("blood")
		
		# Рассчитываем длительность анимации
		var frame_count = animated_sprite.sprite_frames.get_frame_count("blood")
		var fps = animated_sprite.sprite_frames.get_animation_speed("blood")
		var duration = frame_count / fps
		
		# Удаляем через это время
		await get_tree().create_timer(duration).timeout
		queue_free()
	else:
		queue_free()
