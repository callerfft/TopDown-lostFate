extends Control

# Статистика
@onready var kills_label: Label = $StaticConteiner/KillsLabel
@onready var level_label: Label = $StaticConteiner/LevelLabel
@onready var exp_label: Label = $StaticConteiner/ExpLabel
@onready var wave_label: Label = $StaticConteiner/WaveLabel
@onready var coins_label: Label = $StaticConteiner/CoinsLabel
@onready var artifacts_label: Label = $StaticConteiner/ArtifactsLabel

# Таймер волны
@onready var wave_timer_container: VBoxContainer = $WaveTimerContainer
@onready var timer_label: Label = $WaveTimerContainer/TimerLabel
@onready var skip_button: Button = $WaveTimerContainer/SkipButton

var wave_manager: Node

func _ready() -> void:
	# Подключаем сигналы GameManager
	GameManager.kills_changed.connect(_on_kills_changed)
	GameManager.level_up.connect(_on_level_up)
	GameManager.exp_changed.connect(_on_exp_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.artifacts_changed.connect(_on_artifacts_changed)
	
	# Подключаем кнопку
	skip_button.pressed.connect(_on_skip_button_pressed)
	
	# Находим WaveManager с задержкой
	call_deferred("setup_wave_manager")
	
	# Инициализируем UI с текущими значениями
	await get_tree().process_frame  # Добавь эту строку
	update_all_labels()  # Переместил сюда
	wave_timer_container.visible = false
func setup_wave_manager() -> void:
	wave_manager = get_tree().get_first_node_in_group("wave_manager")
	if wave_manager:
		if wave_manager.has_signal("wave_completed"):
			wave_manager.wave_completed.connect(_on_wave_completed)
		if wave_manager.has_signal("wave_started"):
			wave_manager.wave_started.connect(_on_wave_started)
func _process(_delta: float) -> void:
	# Обновляем таймер
	if wave_timer_container.visible and wave_manager:
		var time_left = wave_manager.wave_timer.time_left
		timer_label.text = "Next wave in: %d" % int(time_left)
	
	# Скип по пробелу
	if Input.is_action_just_pressed("ui_accept") and wave_timer_container.visible:
		_on_skip_button_pressed()

func update_all_labels() -> void:
	kills_label.text = "Kills: %d" % GameManager.total_kills
	level_label.text = "Level: %d" % GameManager.player_level
	exp_label.text = "EXP: %d / %d" % [GameManager.current_exp, GameManager.exp_to_next_level]
	wave_label.text = "Wave: %d" % GameManager.current_wave
	coins_label.text = "Coins: %d" % GameManager.coins
	artifacts_label.text = "Artifacts: %d" % GameManager.artifacts

func _on_kills_changed(kills: int) -> void:
	kills_label.text = "Kills: %d" % kills

func _on_level_up(new_level: int) -> void:
	level_label.text = "Level: %d" % new_level

func _on_exp_changed(current: int, needed: int) -> void:
	exp_label.text = "EXP: %d / %d" % [current, needed]

func _on_wave_changed(wave_number: int) -> void:
	wave_label.text = "Wave: %d" % wave_number

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Coins: %d" % coins

func _on_artifacts_changed(artifacts: int) -> void:
	artifacts_label.text = "Artifacts: %d" % artifacts

func _on_wave_completed() -> void:
	wave_timer_container.visible = true

func _on_wave_started(_wave_number: int) -> void:
	wave_timer_container.visible = false

func _on_skip_button_pressed() -> void:
	if wave_manager and wave_manager.can_skip_timer:
		wave_manager.skip_wave_timer()
