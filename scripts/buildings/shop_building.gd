extends StaticBody2D

@onready var interaction_area: Area2D = $Area2D
@onready var interact_button: Button = $CanvasLayer/InteractButton
@onready var shop_menu: Control = get_tree().get_first_node_in_group("shop_menu")
@onready var open_model: Sprite2D = $ShopModels/OpenModel
@onready var closed_model: Sprite2D = $ShopModels/ClosedModel
#@onready var shop_menu_1: Control = $UI/ShopMenu

var player_nearby: bool = false
var is_wave_active: bool = false
var is_shop_open: bool = false

func _ready() -> void:
	# Подключаем interaction area
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	# Подключаем кнопку
	if interact_button:
		interact_button.pressed.connect(open_shop)
		interact_button.visible = false

	# Подключаемся к волнам
	var wave_manager = get_tree().get_first_node_in_group("wave_manager")
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)

	# Подключаемся к магазину
	if shop_menu:
		shop_menu.shop_opened.connect(_on_shop_opened)
		shop_menu.shop_closed.connect(_on_shop_closed)

	# Обновляем визуальное состояние
	_update_shop_model()

func _process(_delta: float) -> void:
	pass  # Кнопка обрабатывает взаимодействие

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		_update_button_visibility()

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		_update_button_visibility()

func _update_button_visibility() -> void:
	if interact_button:
		# Кнопка видна только если: игрок рядом И волна не активна И магазин закрыт
		var should_show = player_nearby and not is_wave_active and not is_shop_open
		interact_button.visible = should_show
func _on_interact_button_pressed() -> void:
	if player_nearby and not is_wave_active:
		open_shop()

func open_shop() -> void:
	if shop_menu and not is_wave_active:
		shop_menu.show_shop()

func _on_wave_started(_wave_number: int) -> void:
	is_wave_active = true
	
	# Закрываем магазин если он открыт
	if shop_menu:
		shop_menu.hide_shop()
		shop_menu.set_locked(true)
	
	# Скрываем кнопку
	_update_button_visibility()
	
	# Обновляем модель
	_update_shop_model()

func _on_wave_completed() -> void:
	is_wave_active = false
	
	# Разблокируем магазин
	if shop_menu:
		shop_menu.set_locked(false)
	
	# Показываем кнопку если игрок рядом
	_update_button_visibility()
	
	# Обновляем модель
	_update_shop_model()

func _update_shop_model() -> void:
	# Обновляем визуальное состояние магазина
	if open_model and closed_model:
		if is_wave_active:
			# Во время волны магазин закрыт
			open_model.visible = false
			closed_model.visible = true
		else:
			# Между волнами магазин открыт
			open_model.visible = true
			closed_model.visible = false

func _on_shop_opened() -> void:
	is_shop_open = true
	_update_button_visibility()

func _on_shop_closed() -> void:
	is_shop_open = false
	_update_button_visibility()
