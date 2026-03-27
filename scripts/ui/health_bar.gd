extends ProgressBar
@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $DamageBar

func _ready():
	# предполагая, что health_bar — это сам этот скрипт, а игрок где-то доступен
	var player = get_tree().get_first_node_in_group("player")  # или другой способ
	if player:
		player.health_changed.connect(_on_player_health_changed)
	else:
		pass
func _on_player_health_changed(new_hp: int):
	health = new_hp   # вызовет setter → обновит value и damage_bar

var health = 0: set = _set_health
func _set_health(new_health):
	#print("HealthBar got:", new_health)
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	if health <= 0:
		queue_free()
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health
func init_health(_health) -> void:
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
func _on_timer_timeout() -> void:
	damage_bar.value = health
