extends Area2D

var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 3.0

func _ready() -> void:
	# Удаляем через 3 секунды
	if has_node("Timer"):
		$Timer.wait_time = lifetime
		$Timer.one_shot = true
		$Timer.timeout.connect(queue_free)
		$Timer.start()
	else:
		var timer = Timer.new()
		timer.wait_time = lifetime
		timer.one_shot = true
		timer.timeout.connect(queue_free)
		add_child(timer)
		timer.start()
	
	# При попадании в врага
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	print("💥 Bullet created at: ", global_position, " direction: ", direction)

func _process(delta: float) -> void:
	# ВАЖНО: используем global_position вместо position
	global_position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	print("🎯 Bullet direction set to: ", direction)

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent.is_in_group("enemy"):
		hit_enemy(parent)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		hit_enemy(body)

func hit_enemy(enemy: Node2D) -> void:
	print("💥 Turret bullet hit enemy: ", enemy.name)
	
	if enemy.has_method("take_damage"):
		enemy.take_damage(1)  # 1 урон от пули
	
	queue_free()
