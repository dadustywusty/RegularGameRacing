extends Node

# Ajusta esse valor pro quanto quer abafar
# 500 = muito abafado | 1000 = padrão | 2000 = sutil
const CUTOFF_HZ := 1200.0

var _lowpass: AudioEffectLowPassFilter
var _bus_idx: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bus_idx = AudioServer.get_bus_index("Musica")
	
	if _bus_idx == -1:
		push_error("PauseAudio: bus 'Musica' não existe!")
		return
	
	_lowpass = AudioEffectLowPassFilter.new()
	_lowpass.cutoff_hz = CUTOFF_HZ
	AudioServer.add_bus_effect(_bus_idx, _lowpass)
	
	# Começa desligado
	var efeito_idx = AudioServer.get_bus_effect_count(_bus_idx) - 1
	AudioServer.set_bus_effect_enabled(_bus_idx, efeito_idx, false)

func _notification(what: int) -> void:
	if _bus_idx == -1:
		return
	
	var efeito_idx = AudioServer.get_bus_effect_count(_bus_idx) - 1
	
	match what:
		NOTIFICATION_PAUSED:
			AudioServer.set_bus_effect_enabled(_bus_idx, efeito_idx, true)
		NOTIFICATION_UNPAUSED:
			AudioServer.set_bus_effect_enabled(_bus_idx, efeito_idx, false)
