extends CharacterBody2D

signal enemy_died  # ЭТУ СТРОКУ НУЖНО ДОБАВИТЬ В САМОЕ НАЧАЛО!

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100
var damage_area = null
var is_dead = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_dead:
		return
		
	var direction = get_direction_to_player()
	velocity = speed * direction
	move_and_slide()
	
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("move")  # Предполагаю что анимация бега называется "run"
	else:
		animated_sprite_2d.play("default")
	
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - global_position).normalized()
	return Vector2.ZERO

func _on_area_2d_area_entered(_area: Area2D) -> void:
	is_dead = true
	speed = 0
	$orcSound.play()
	animated_sprite_2d.play("hurt")
	
	print("killed")
	print("Emitting enemy_died signal")
	enemy_died.emit()  # Теперь это сработает!
	
	await animated_sprite_2d.animation_finished
	
	queue_free()
