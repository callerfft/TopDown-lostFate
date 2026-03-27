extends Area2D

var velocity = Vector2.ZERO
#var gravity = 400 # Сила, тянущая монету вниз
var friction = 0.9 # Насколько быстро монета остановится на земле

func _ready():
	# При появлении даем случайный пинок вверх и в бок
	velocity = Vector2(randf_range(-100, 100), randf_range(-150, -250))

func _process(delta):
	# Если монета выше "уровня пола" (условно), она падает
	# В простом 2Д без физики мы просто двигаем её по velocity
	velocity.y += gravity * delta
	position += velocity * delta
	
	# Небольшое трение, чтобы она не летела бесконечно вбок
	velocity.x *= friction

# Подключи сигнал body_entered от Area2D к этой функции
func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		collect()

func collect():
	# Логика подбора (звук, частицы, прибавка к счету)
	print("Монета подобрана!")
	queue_free()
