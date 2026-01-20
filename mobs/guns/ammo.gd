extends Node2D
# сама скорость снаряда
const SPEED: int = 500

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	# система сглаживания скорости снаряда  

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
#система исчезновения после выхода из поля зрения

@warning_ignore("unused_parameter")
func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
	
	pass
#система пробития снаряда
