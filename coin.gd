extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D

var move_speed: float = 200.0
var pickup_range: float = 100.0  # Дистанция на которой монета начинает лететь к игроку
var player: Node2D = null
var is_collected: bool = false

func _ready() -> void:
	add_to_group("drops")
	
	# Проигрываем анимацию (если есть)
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play("default")  # Или название твоей анимации
	
	# Анимация появления
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _process(delta: float) -> void:
	# Находим игрока поблизости
	if not player:
		player = get_tree().get_first_node_in_group("player") as Node2D
	
	if player and not is_collected:
		var distance = global_position.distance_to(player.global_position)
		
		# Если игрок близко - начинаем лететь к нему
		if distance < pickup_range:
			is_collected = true
	
	# Летим к игроку
	if is_collected and player:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * move_speed * delta
		move_speed += 500 * delta
		
		# Если долетели - подбираем
		if global_position.distance_to(player.global_position) < 20:
			collect()

func collect() -> void:
	if not is_instance_valid(self):
		return
	
	# Добавляем монеты
	GameManager.add_coins(1)
	
	# Анимация сбора
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(queue_free)
