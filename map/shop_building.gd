extends StaticBody2D

@onready var interaction_area: Area2D = $Area2D
@onready var interaction_prompt: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var player_nearby: bool = false
var shop_menu: Control = null
var is_wave_active: bool = false

func _ready() -> void:
	# Подключаем interaction area
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	# Находим ShopMenu в UI
	await get_tree().process_frame
	shop_menu = get_tree().get_first_node_in_group("shop_menu")
	
	if not shop_menu:
		print("❌ ShopMenu not found! Add it to 'shop_menu' group")
	
	# Подключаемся к волнам
	var wave_manager = get_tree().get_first_node_in_group("wave_manager")
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)
	
	interaction_prompt.visible = false

func _process(_delta: float) -> void:
	# Открытие магазина по E
	if player_nearby and Input.is_action_just_pressed("interact") and not is_wave_active:
		open_shop()

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		
		if not is_wave_active:
			interaction_prompt.visible = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interaction_prompt.visible = false

func open_shop() -> void:
	if shop_menu and not is_wave_active:
		shop_menu.show_shop()
		print("🛒 Shop opened!")

func _on_wave_started(_wave_number: int) -> void:
	is_wave_active = true
	interaction_prompt.visible = false
	
	# Анимация закрытия (магазин прячется)
	if anim_player.has_animation("close"):
		anim_player.play("close")
	
	print("🏪 Shop closed - wave started!")

func _on_wave_completed() -> void:
	is_wave_active = false
	
	# Анимация открытия (магазин появляется)
	if anim_player.has_animation("open"):
		anim_player.play("open")
	
	# Показываем подсказку если игрок рядом
	if player_nearby:
		interaction_prompt.visible = true
	
	print("🏪 Shop available!")
