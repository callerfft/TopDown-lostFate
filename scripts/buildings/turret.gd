extends StaticBody2D

@onready var shoot_timer: Timer = $shootTimer
@onready var detection_area: Area2D = $directionArea
@onready var sprite: AnimatedSprite2D = $Sprite2D
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 1.0
@export var detection_range: float = 700.0

var enemies_in_range = []
var current_target: Node2D = null

func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()
	
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	detection_area.area_entered.connect(_on_area_entered)
	detection_area.area_exited.connect(_on_area_exited)
	
	print("🔫 Turret ready!")

func _process(_delta: float) -> void:
	find_closest_enemy()
	
	if current_target and is_instance_valid(current_target):
		look_at(current_target.global_position)

func find_closest_enemy() -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	if enemies_in_range.is_empty():
		current_target = null
		return
	
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
		print("X No bullet scene assigned!")
		return
	
	print("Turret shooting at: ", target.name)
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	var direction = (target.global_position - global_position).normalized()
	bullet.rotation = direction.angle()
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)
			print("-- Enemy entered range: ", body.name)

func _on_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)
	print("-- Enemy left range")

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent.is_in_group("enemy"):
		if not enemies_in_range.has(parent):
			enemies_in_range.append(parent)
			print("-- Enemy area entered range: ", parent.name)

func _on_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	enemies_in_range.erase(parent)
