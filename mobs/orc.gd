extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100
var damage_area = null 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var direction = get_direction_to_player()
	velocity = speed * direction
	move_and_slide()
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("move")
	else:
		animated_sprite_2d.play("default")
	var face_sign = sign(direction.x)
	if face_sign != 0: 
			animated_sprite_2d.scale.x = face_sign
func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - self.global_position).normalized()
	return Vector2.ZERO
	
func _on_area_2d_area_entered(_area: Area2D) -> void:
	$orcSound.play()
	print("killed")
	#await $orcSound.finished
	queue_free()
	pass # Replace with function body.
	
	
#
	#
#func _physics_process(_delta: float) -> void:
		#if damage_area != null:
			#take_damage()
			#$Inv.start()
			#
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#damage_area = area
#func _on_hit_box_area_exited(area: Area2D) -> void:
	#if area == damage_area:
		#damage_area = null
#func take_damage():
	#print("hitOrc")
