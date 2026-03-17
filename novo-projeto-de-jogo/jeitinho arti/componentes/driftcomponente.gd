extends Node
class_name DriftComponente

@onready var movimento_componente: MovimentoComponente = %MovimentoComponente
@onready var turbo: TurboComponente = $"../turbo"

@export var tempo_para_turbo: float = 0.75
var _timer_drift: float = 0.0
var turbo_carregado: bool = false

var angulo_base
var angulo_drift
var drift := false

func _ready() -> void:
	angulo_base = movimento_componente.angulo
	angulo_drift = movimento_componente.angulo * 1.2

func tick() -> void:
	if drift:
		movimento_componente.angulo = angulo_drift
	else:
		movimento_componente.angulo = angulo_base
	if drift:
		_timer_drift += get_process_delta_time()
		if _timer_drift >= tempo_para_turbo:
			turbo_carregado = true
	else:
		if turbo_carregado:
			turbo.ativar()
			turbo_carregado = false
		_timer_drift = 0.0
