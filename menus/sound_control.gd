extends HSlider
@export var audio: String

var audio_bus_id
func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index("sound")

func _on_value_changed(_value: float) -> void:
	AudioServer.set_bus_volume_db(audio_bus_id,value)
	print(int(value))
