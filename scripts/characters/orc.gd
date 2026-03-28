extends CharacterBody2D

signal enemy_died

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var blood_effect_scene: PackedScene
@export var coin_scene: PackedScene
@export var artifact_scene: PackedScene

var speed = 100
var is_dead = false
var has_notified_wave_manager = false
var drop_chance: float = 0.9  # 90% шанс выпадения монеты

func _ready() -> void:
	
	pass

func _physics_process(delta):
	if is_dead:
		return

	if Input.is_action_just_pressed("kill all"):
		kill_all()

	var direction = get_direction_to_player()
	velocity = speed * direction
	move_and_slide()

	if velocity.length() > 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("default")

	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

func _process(_delta: float) -> void:
	if is_dead:
		return
	if Input.is_action_just_pressed("kill all"):
		kill_all()
	

func kill_all():
	is_dead = true
	speed = 0

	#animated_sprite_2d.stop()
	# отключение всех коллизии
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)

	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)

	if has_node("orcSound"):
		$orcSound.play()

	animated_sprite_2d.play("hurt")

	call_deferred("spawn_effects")
	call_deferred("notify_wave_manager")

	await animated_sprite_2d.animation_finished

	queue_free()

func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - global_position).normalized()
	return Vector2.ZERO

func _on_area_2d_area_entered(_area: Area2D) -> void:
	if is_dead:
		return
	#if Input.is_action_just_pressed("kill all"):
		#is_dead = true
	is_dead = true
	speed = 0
	
	# отключение всех коллизии
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	
	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)
	
	if has_node("orcSound"):
		$orcSound.play()
	
	animated_sprite_2d.play("hurt")
	
	call_deferred("spawn_effects")
	call_deferred("notify_wave_manager")
	
	await animated_sprite_2d.animation_finished
	
	queue_free()

func notify_wave_manager() -> void:
	if has_notified_wave_manager:
		return

	has_notified_wave_manager = true

	var wave_mgr = get_tree().get_first_node_in_group("wave_manager")
	if wave_mgr and wave_mgr.has_method("on_enemy_killed"):
		wave_mgr.on_enemy_killed()

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

	var drop_instance: Node2D = null

	# Всегда спавним монету (90% шанс)
	if coin_scene:
		drop_instance = coin_scene.instantiate()

	if drop_instance:
		get_parent().add_child(drop_instance)
		drop_instance.global_position = global_position

		var random_offset = Vector2(randf_range(-12, 12), randf_range(-12, 12))
		var tween = create_tween()
		tween.tween_property(drop_instance, "global_position", global_position + random_offset, 0.3).set_ease(Tween.EASE_OUT)
