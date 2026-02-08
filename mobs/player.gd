extends CharacterBody2D

signal health_changed(new_hp: int)

@onready var death_screen: Control = $deathScreen/CanvasLayer/deathScreen
@onready var timer = $Inv2
@onready var animated_sprite_2d: AnimatedSprite2D = $playerAnim
@onready var pause_button: Button = $"../pauseSystem/CanvasLayer/pauseButton"
@onready var health_bar: ProgressBar = $HealthBar
@onready var waveUI: CanvasLayer = $"../wave + exp UI"
@onready var camera: Camera2D = $Camera2D 
@export var turret_scene: PackedScene
@export var trap_scene: PackedScene
@export var wall_scene: PackedScene
 
func handle_building() -> void:
	# Турель (T)
	if Input.is_action_just_pressed("build_turret") and GameManager.upgrades.turret_count > 0:
		place_building(turret_scene)
		GameManager.upgrades.turret_count -= 1
		GameManager.emit_stats()
	
	# Ловушка (Y)
	if Input.is_action_just_pressed("build_trap") and GameManager.upgrades.trap_count > 0:
		place_building(trap_scene)
		GameManager.upgrades.trap_count -= 1
		GameManager.emit_stats()
	
	# Стена (U)
	if Input.is_action_just_pressed("build_wall") and GameManager.upgrades.wall_count > 0:
		place_building(wall_scene)
		GameManager.upgrades.wall_count -= 1
		GameManager.emit_stats()

func place_building(building_scene: PackedScene) -> void:
	if not building_scene:
		print("❌ Building scene not assigned!")
		return
	
	var building = building_scene.instantiate()
	get_parent().add_child(building)
	 
	var offset = Vector2(50, 0) * animated_sprite_2d.scale.x
	building.global_position = global_position + offset
	
	print("🏗️ Building placed!") 
var max_hp: int:
	get:
		return GameManager.upgrades.max_hp
var hp: int:
	get:
		return GameManager.upgrades.current_hp
	set(value):
		GameManager.upgrades.current_hp = clamp(value, 0, max_hp)
		
		 
		if is_instance_valid(health_bar) and health_bar != null:
			health_bar.health = GameManager.upgrades.current_hp
		
		health_changed.emit(GameManager.upgrades.current_hp)
var max_speed: float:
	get:
		return GameManager.upgrades.move_speed

# Способности
var dash_cooldown: float = 0.0
var dash_speed: float = 400.0
var dash_duration: float = 0.2
var is_dashing: bool = false

var heal_cooldown: float = 0.0
var heal_cooldown_max: float = 30.0

var shield_active: bool = false
var shield_cooldown: float = 0.0
var shield_cooldown_max: float = 45.0
var shield_duration: float = 3.0

var enemies_colliding = 0
var damage_area = null
var acceleration = 0.5

func _ready():
	add_to_group("player")
	get_tree().paused = false
	waveUI.visible = true
	death_screen.visible = false
	pause_button.visible = true
	timer.start()
	GameManager.upgrades.turret_count = 99
	GameManager.emit_stats()
	print("turrets for testing")
	 
	health_bar.init_health(hp)

func _input(event: InputEvent) -> void:
	# Отладка HP
	if event.is_action_pressed("hp + 1"):
		hp += 1
		print("HP: ", hp)
	if event.is_action_pressed("hp + 100"):
		hp += 100
		print("HP: ", hp)
	if event.is_action_pressed("damage"):
		hp -= 1
		print("HP: ", hp)

func _process(delta: float) -> void:
	
	if dash_cooldown > 0:
		dash_cooldown -= delta
	if heal_cooldown > 0:
		heal_cooldown -= delta
	if shield_cooldown > 0:
		shield_cooldown -= delta
	
	#  способности
	handle_abilities()
	handle_building() 
	# Движение
	if not is_dashing:
		handle_movement()

func handle_movement() -> void:
	var movement = movement_vector()
	var direction = movement.normalized()
	var target_velocity = max_speed * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()
	
	# Анимация
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("move")
	else:
		animated_sprite_2d.play("default")
	
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

func movement_vector():
	var movement_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var movement_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(movement_x, movement_y)

func handle_abilities() -> void:
	# Dash (Shift)
	if GameManager.upgrades.has_dash and Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
		activate_dash()
	
	# Heal (H)
	if GameManager.upgrades.has_heal and Input.is_action_just_pressed("heal") and heal_cooldown <= 0:
		activate_heal()
	
	# Shield (G)
	if GameManager.upgrades.has_shield and Input.is_action_just_pressed("shield") and shield_cooldown <= 0:
		activate_shield()

func activate_dash() -> void:
	is_dashing = true
	dash_cooldown = 5.0
	
	var dash_direction = movement_vector()
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT * animated_sprite_2d.scale.x
	
	velocity = dash_direction.normalized() * dash_speed
	
	print("Dash!")
	$sounds/playerHurt.play()  # Можешь добавить отдельный звук для dash
	
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

func activate_heal() -> void:
	hp = min(hp + 2, max_hp)
	heal_cooldown = heal_cooldown_max
	
	print("💚 Healed! HP: ", hp, "/", max_hp)
	$sounds/regenSound.play()
	$AnimationPlayer.play("heal")

func activate_shield() -> void:
	shield_active = true
	shield_cooldown = shield_cooldown_max
	
	# Визуальный эффект щита
	modulate = Color(0.5, 0.5, 1.0)
	
	print("🛡️ Shield activated!")
	
	await get_tree().create_timer(shield_duration).timeout
	shield_active = false
	modulate = Color(1, 1, 1)
	print("🛡️ Shield deactivated")

func take_damage():
	#   щит
	if shield_active:
		print("🛡️ Damage blocked by shield!")
		return
	
	hp -= 1
	$sounds/playerHurt.play()
	$AnimationPlayer.play("hurt")
	
	# Тряска камеры
	shake_camera()
	
	print("HP: ", hp)
	
	# Смерть
	if hp <= 0:
		die()

func shake_camera() -> void:
	if not camera:
		return
	
	var shake_strength = 5.0
	var shake_duration = 0.3
	var original_offset = camera.offset
	
	var tween = create_tween()
	
	for i in range(5):
		var random_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		tween.tween_property(camera, "offset", random_offset, shake_duration / 5.0)
	
	tween.tween_property(camera, "offset", original_offset, shake_duration / 5.0)

func die() -> void:
	print(" Player died!")
	get_tree().paused = true
	waveUI.visible = false
	death_screen.visible = true
	pause_button.visible = false

func _physics_process(_delta: float) -> void:
	if timer.is_stopped():
		timer.start()
		if damage_area != null:
			take_damage()
			timer.start()

func _on_hit_box_area_entered(area: Area2D) -> void:
	damage_area = area

func _on_hit_box_area_exited(area: Area2D) -> void:
	if area == damage_area:
		damage_area = null

func _on_area_2d_area_entered(area: Area2D) -> void:
	if hp < max_hp:
		hp += 1
		print("regeneration")
		$sounds/regenSound.play()
		$AnimationPlayer.play("heal")
	else:
		print("max hp")
