extends CharacterBody2D
signal health_changed(new_hp: int)
@onready var death_screen: Control = $deathScreen/CanvasLayer/deathScreen
@onready var timer = $Inv2
@onready var animated_sprite_2d: AnimatedSprite2D = $playerAnim
@onready var pause_button: Button = $"../pauseSystem/CanvasLayer/pauseButton"
@onready var health_bar: ProgressBar = $HealthBar
@export var max_hp := 5  


#@export var regen_amount := 1
#@export var regen_delay := 2.0   # сек после урона
#@export var regen_interval := 1.0 # шаг регена
#@onready var regen_delay_timer: Timer = $regenDelay
#@onready var regen_timer: Timer = $regenTimer
var hp := max_hp
##hui pizda


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hp+"):
		hp = hp + 100
		print(hp)
		pass
func _ready():
	get_tree().paused = false
	death_screen.visible = false
	pause_button.visible = true
	timer.start()
	health_bar.init_health(hp)
#@onready var health_component: HealthComponent = $HealthComponent
#@onready var grace_period: Timer = $grace_period
var enemies_colliding = 0   
var damage_area = null 
var max_speed = 200
var acceleration = .5
func _on_area_2d_area_entered(area: Area2D) -> void: #hp regen
	if hp < 5:
		hp = hp + 1
		health_changed.emit(hp)
		print("regeneration")
		$sounds/regenSound.play()
		print(hp)
		health_bar.health = hp
	else:
		print("max hp")
	pass # Replace with function body.
func movement_vector():
	var movement_x = Input.get_action_strength("right") - Input.get_action_strength("left") 	
	var movement_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(movement_x,movement_y)
func _process(_delta):
	var movement = movement_vector()
	var direction = movement.normalized()
	var target_velocity = max_speed * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("move")
	else:
		animated_sprite_2d.play("default")
	var face_sign = sign(direction.x)
	if face_sign != 0: 
			animated_sprite_2d.scale.x = face_sign
func take_damage():
	hp -= 1
	$sounds/playerHurt.play()
	$AnimationPlayer.play("hurt")
	print(hp)
	health_bar.health = hp 
	if hp <= 0:
		get_tree().paused = true
		death_screen.visible = true
		pause_button.visible = false
func _physics_process(_delta: float) -> void:
	if timer.is_stopped():
		timer.start()
		if damage_area != null:
			take_damage()
			timer.start()
func _on_hit_box_area_entered(area: Area2D) -> void:
	damage_area = area
func _on_hit_box_area_exited(area: Area2D) -> void:
	if area == damage_area:
		damage_area = null
	
#func take_damage():
	
	
	#hp -= 1
	#if hp <= 0 :
		#get_tree().paused = true
		#death_screen.visible = true
		#pause_button.visible = false
		#health_bar.health = hp
	########print("hit")
#func start_regen():
	#if hp < max_hp and regen_timer.is_stopped():
		#regen_timer.start(regen_interval)
#func _on_regen_timer_timeout():
	#hp = min(hp + regen_amount, max_hp)
	#health_bar.health = hp
#
	#if hp >= max_hp:
		#regen_timer.stop()
#func _on_regen_delay_timer_timeout():
	#start_regen()
