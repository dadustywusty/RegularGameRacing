extends Node
class_name TurboComponente

@onready var movimento_componente: MovimentoComponente = %MovimentoComponente
@onready var fumaça: GPUParticles3D = $"../carro(1)/Fumaça"
@export var forca_turbo: float
@export var duracao_turbo: float

var _timer_turbo: float = 0.0
var ativo: bool = false
func _ready() -> void:
	fumaça.emitting = false


func ativar() -> void:
	_timer_turbo = duracao_turbo
	ativo = true
	fumaça.emitting = true 

func tick(delta: float) -> void:
	if ativo:
		_timer_turbo -= delta
		movimento_componente.velocidade_turbo = forca_turbo
		if _timer_turbo <= 0.0:
			ativo = false
			fumaça.emitting = false
			movimento_componente.velocidade_turbo = 0.0
