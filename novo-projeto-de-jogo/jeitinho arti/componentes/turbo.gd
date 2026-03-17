extends Node
class_name TurboComponente

@onready var movimento_componente: MovimentoComponente = %MovimentoComponente

@export var forca_turbo: float = 80.0
@export var duracao_turbo: float = 0.3

var _timer_turbo: float = 0.0
var ativo: bool = false

func ativar() -> void:
	_timer_turbo = duracao_turbo
	ativo = true

func tick(delta: float) -> void:
	if ativo:
		_timer_turbo -= delta
		movimento_componente.velocidade_turbo = forca_turbo
		if _timer_turbo <= 0.0:
			ativo = false
			movimento_componente.velocidade_turbo = 0.0
