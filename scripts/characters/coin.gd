extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var friction = 0.95
var is_collecting = false
var target_player = null
var is_collected = false
var is_on_floor = false

# Настройки
@export var coin_value: int = 1
@export var pickup_range: float = 150.0  # Дистанция подбора
@export var magnet_speed: float = 500.0  # Скорость притягивания
@export var coin_scale: float = 0.5  # Размер монеты

@onready var pickup_sound: AudioStreamPlayer = $pickupSound
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D

var _initial_y: float = 0.0

func _ready():
	scale = Vector2.ONE * coin_scale
	velocity = Vector2(randf_range(-150, 150), randf_range(-200, -400))
	_initial_y = global_position.y

func _physics_process(delta):
	if is_collected:
		return
	
	_find_player()
		
	if is_collecting and is_instance_valid(target_player):
		var direction = (target_player.global_position - global_position).normalized()
		velocity = direction * magnet_speed
		move_and_slide()
		
		if global_position.distance_to(target_player.global_position) < 20.0:
			_animate_pickup()
	else:
		if not is_on_floor:
			velocity.y += gravity * delta
			move_and_slide()
			velocity.x *= friction
			
			if global_position.y >= _initial_y:
				global_position.y = _initial_y
				velocity = Vector2.ZERO
				is_on_floor = true

func _find_player():
	if is_collected:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance <= pickup_range:
			target_player = player
			is_collecting = true

func _animate_pickup():
	if is_collected:
		return
	is_collected = true
	
	if collision_shape:
		collision_shape.disabled = true
	if area:
		area.monitoring = false
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 0.75, 0.15)
	tween.parallel().tween_property(self, "position:y", position.y - 30, 0.15)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	
	tween.tween_callback(_collect)

func _collect():
	GameManager.add_coins(coin_value)
	GameManager.add_currency(coin_value)
	
	if pickup_sound and pickup_sound.stream:
		pickup_sound.play()
	
	queue_free()

func _on_area_2d_body_entered(body):
	if is_collected:
		return
	if body.is_in_group("player"):
		target_player = body
		is_collecting = true
