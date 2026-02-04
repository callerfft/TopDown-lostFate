extends StaticBody2D

@onready var shoot_timer: Timer = $shootTimer
@onready var detection_area: Area2D = $directionArea
@onready var sprite: AnimatedSprite2D = $Sprite2D
 

@export var bullet_scene: PackedScene
@export var shoot_interval: float = 1.0
@export var damage: float = 1.0
@export var detection_range: float = 300.0

var enemies_in_range = []
var current_target: Node2D = null

func _ready() -> void:
	# Настраиваем таймер
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()
	
	# Подключаем detection area
	detection_area.body_entered.connect(_on_enemy_entered)
	detection_area.body_exited.connect(_on_enemy_exited)
	detection_area.area_entered.connect(_on_enemy_area_entered)
	detection_area.area_exited.connect(_on_enemy_area_exited)

func _process(_delta: float) -> void:
	# Находим ближайшего врага
	find_closest_enemy()
	
	# Поворачиваемся к цели
	if current_target and is_instance_valid(current_target):
		look_at(current_target.global_position)

func find_closest_enemy() -> void:
	# Убираем невалидных врагов
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy))
	
	if enemies_in_range.is_empty():
		current_target = null
		return
	
	# Находим ближайшего
	var closest_distance = INF
	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			current_target = enemy

func _on_shoot_timer_timeout() -> void:
	if current_target and is_instance_valid(current_target):
		shoot_at(current_target)

func shoot_at(target: Node2D) -> void:
	if not bullet_scene:
		return
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	# Направляем пулю к цели
	var direction = (target.global_position - global_position).normalized()
	bullet.rotation = direction.angle()
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)

func _on_enemy_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.name.contains("orc"):
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)

func _on_enemy_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)

func _on_enemy_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and (parent.is_in_group("enemy") or parent.name.contains("orc")):
		if not enemies_in_range.has(parent):
			enemies_in_range.append(parent)

func _on_enemy_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	enemies_in_range.erase(parent)
