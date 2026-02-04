extends Control
#@onready var kills_label: Label = $StatsConteiner/KillsLabel

# Статистика
@onready var kills_label: Label = $StatsContainer/KillsLabel
@onready var level_label: Label = $StatsContainer/LevelLabel
@onready var exp_label: Label = $StatsContainer/ExpLabel
@onready var wave_label: Label = $StatsContainer/WaveLabel
@onready var coins_label: Label = $StatsContainer/CoinsLabel
@onready var artifacts_label: Label = $StatsContainer/ArtifactsLabel
@onready var wave_timer_container: VBoxContainer = $WaveTimerContainer
@onready var timer_label: Label = $WaveTimerContainer/TimerLabel
@onready var skip_button: Button = $WaveTimerContainer/SkipButton
# Добавь в начало с другими @onready
@onready var hp_label: Label = $StatsContainer/HPLabel
@onready var turret_label: Label = $StatsContainer/turretCount
 
var wave_manager: Node

func _ready() -> void:
	# Подключаем ОДИН сигнал вместо 6
	GameManager.stats_updated.connect(update_all_labels)
	GameManager.level_up.connect(_on_level_up)
	
	# Находим WaveManager с задержкой
	call_deferred("setup_wave_manager")
	
	# Подключаем кнопку
	skip_button.pressed.connect(_on_skip_button_pressed)
	
	# Инициализируем UI
	wave_timer_container.visible = false
	update_all_labels()

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

# ОДНА функция обновления всего UI
func update_all_labels() -> void:
	if GameManager.upgrades.turret_count > 0:
		turret_label.text = "Turrets: %d (T)" % GameManager.upgrades.turret_count
		turret_label.visible = true
	else:
		turret_label.visible = false
	kills_label.text = "Kills: %d" % GameManager.total_kills
	level_label.text = "Level: %d" % GameManager.player_level
	exp_label.text = "EXP: %d / %d" % [GameManager.current_exp, GameManager.exp_to_next_level]
	wave_label.text = "Wave: %d" % GameManager.current_wave
	coins_label.text = "Coins: %d" % GameManager.coins
	artifacts_label.text = "Artifacts: %d" % GameManager.artifacts
	hp_label.text = "HP: %d / %d" % [GameManager.upgrades.current_hp, GameManager.upgrades.max_hp]
func _on_level_up(new_level: int) -> void:
	print("LEVEL UP! New level: %d" % new_level)

func _on_wave_completed() -> void:
	wave_timer_container.visible = true

func _on_wave_started(_wave_number: int) -> void:
	wave_timer_container.visible = false

func _on_skip_button_pressed() -> void:
	if wave_manager and wave_manager.can_skip_timer:
		wave_manager.skip_wave_timer()
