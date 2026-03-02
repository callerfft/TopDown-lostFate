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
		# Если нет Timer ноды, создаем
		var timer = Timer.new()
		timer.wait_time = lifetime
		timer.one_shot = true
		timer.timeout.connect(queue_free)
		add_child(timer)
		timer.start()
	
	# При попадании в врага
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Двигаем пулю
	position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()

func _on_area_entered(area: Area2D) -> void:
	# Попали в Area2D орка
	var parent = area.get_parent()
	if parent and parent.is_in_group("enemy"):
		hit_enemy(parent)

func _on_body_entered(body: Node2D) -> void:
	# Попали в тело орка (если он CharacterBody2D)
	if body.is_in_group("enemy"):
		hit_enemy(body)

func hit_enemy(enemy: Node2D) -> void:
	print("💥 Turret bullet hit: ", enemy.name)
	
	# Вызываем функцию смерти врага
	if enemy.has_method("_on_area_2d_area_entered"):
		enemy._on_area_2d_area_entered(self)
	
	# Удаляем пулю
	queue_free()
