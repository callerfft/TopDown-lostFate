extends Node2D
# сама скорость снаряда
const SPEED: int = 500
var attack_damage: int = 2  # Урон пули

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	# система сглаживания скорости снаряда

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
#система исчезновения после выхода из поля зрения

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Проверяем, что это враг
	var enemy = get_enemy_from_area(area)
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(attack_damage)
		print("🔫 Ammo hit enemy: ", enemy.name, " for ", attack_damage, " damage!")
	queue_free()

func get_enemy_from_area(area: Area2D) -> Node2D:
	# Проверяем владельца Area2D
	if area.owner and area.owner.is_in_group("enemy"):
		return area.owner
	# Проверяем родителя
	if area.get_parent() and area.get_parent().is_in_group("enemy"):
		return area.get_parent()
	return null
#система пробития снаряда
