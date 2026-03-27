extends Node
@export var orc: PackedScene


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var random_direction = Vector2.RIGHT.rotated(randf_range(0,TAU))
	var random_distance = randi_range(500,650)
	var spawn_pos = player.global_position + (random_direction * random_distance)
	
	var enemy = orc.instantiate() as Node2D
	get_parent().add_child(enemy)
	enemy.global_position = spawn_pos 
