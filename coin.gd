extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var friction = 0.95 # Трение, чтобы монета не катилась вечно
var is_collecting = false
var target_player = null

func _ready():
	# При появлении даем случайный импульс вверх и в бок
	velocity = Vector2(randf_range(-150, 150), randf_range(-200, -400))

func _physics_process(delta):
	if is_collecting and target_player:
		# Если монета "магнитится" к игроку
		global_position = global_position.move_toward(target_player.global_position, 500 * delta)
		if global_position.distance_to(target_player.global_position) < 10:
			_collect()
	else:
		# Обычная физика падения
		velocity.y += gravity * delta
		move_and_slide()
		velocity.x *= friction # Замедляем по горизонтали

# Присоедини сигнал body_entered от Area2D к этой функции
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"): # Убедись, что игрок в группе "player"
		target_player = body
		is_collecting = true

func _collect():
	# Тут можно добавить звук дзинь или прибавить очки
	print("+1 монета!")
	queue_free()
