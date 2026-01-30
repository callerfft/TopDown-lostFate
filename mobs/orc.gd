extends CharacterBody2D

signal enemy_died

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var blood_effect_scene: PackedScene
@export var coin_scene: PackedScene
@export var artifact_scene: PackedScene

var speed = 100
var is_dead = false
var drop_chance: float = 0.3

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_dead:
		return
		
	var direction = get_direction_to_player()
	velocity = speed * direction
	move_and_slide()
	
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("run")
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
	if is_dead:
		return
	
	is_dead = true
	speed = 0
	
	if has_node("orcSound"):
		$orcSound.play()
	
	animated_sprite_2d.play("hurt")
	
	# Все спавны делаем через call_deferred
	call_deferred("spawn_effects")
	
	print("killed")
	enemy_died.emit()
	
	await animated_sprite_2d.animation_finished
	
	queue_free()

func spawn_effects() -> void:
	spawn_blood()
	spawn_drop()

func spawn_blood() -> void:
	if not blood_effect_scene:
		return
	
	var blood = blood_effect_scene.instantiate()
	get_parent().add_child(blood)
	blood.global_position = global_position

func spawn_drop() -> void:
	if randf() > drop_chance:
		return
	
	var drop_type = randi() % 2
	var drop_instance: Node2D = null
	
	if drop_type == 0 and coin_scene:
		drop_instance = coin_scene.instantiate()
	elif drop_type == 1 and artifact_scene:
		drop_instance = artifact_scene.instantiate()
	
	if drop_instance:
		get_parent().add_child(drop_instance)
		drop_instance.global_position = global_position
		
		# Небольшой отброс
		var random_offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		var tween = create_tween()
		tween.tween_property(drop_instance, "global_position", global_position + random_offset, 0.3).set_ease(Tween.EASE_OUT)
