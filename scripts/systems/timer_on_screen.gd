extends CanvasLayer

@onready var totalTimSec : int = 0
@onready var timer: Timer = $Timer
@onready var label: Label = $Label

func _ready() -> void:
	$Timer.start()
func _on_timer_timeout() -> void:
	#print(totalTimSec)
	totalTimSec += 1
	@warning_ignore("integer_division")
	var m = int(totalTimSec / 60)
	var s = totalTimSec - m * 60
	$Label.text = '%02d:%02d' % [m,s] 
	pass # Replace with function body.
