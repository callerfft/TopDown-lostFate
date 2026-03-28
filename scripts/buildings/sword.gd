extends Area2D

var attack_damage: int = 2  # Урон меча
var attacked_enemies: Array = []  # Список уже атакованных врагов (для кулдауна)

const BULLET = preload("res://scenes/buildings/ammo.tscn")
@onready var muzzle: Marker2D = $Marker2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(_delta: float) -> void:
	# Поворот меча за курсором
	var parent = get_parent()
	if parent:
		look_at(parent.get_global_mouse_position())
	
	# Выстрел по нажатию attack
	if Input.is_action_just_pressed("attack"):
		shoot()

func shoot() -> void:
	var bullet_instance = BULLET.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
	print("🔫 Shot fired!")

func _on_area_entered(area: Area2D) -> void:
	var enemy = get_enemy_from_area(area)
	if enemy and enemy.has_method("take_damage") and not attacked_enemies.has(enemy):
		enemy.take_damage(attack_damage)
		print("⚔️ Sword hit enemy: ", enemy.name, " for ", attack_damage, " damage!")
		attacked_enemies.append(enemy)
		
		# Удаляем врага из списка через 0.5 сек (кулдаун)
		await get_tree().create_timer(0.5).timeout
		if attacked_enemies.has(enemy):
			attacked_enemies.erase(enemy)

func get_enemy_from_area(area: Area2D) -> Node2D:
	# Проверяем владельца Area2D
	if area.owner and area.owner.is_in_group("enemy"):
		return area.owner
	# Проверяем родителя
	if area.get_parent() and area.get_parent().is_in_group("enemy"):
		return area.get_parent()
	return null
