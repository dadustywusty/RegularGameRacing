extends Node
class_name TurboComponente

@onready var movimento_componente: MovimentoComponente = %MovimentoComponente
@onready var fumaça: GPUParticles3D = $"../carro(1)/Fumaça"
@export var forca_turbo: float
@export var duracao_turbo: float

const COR_PADRAO := Color(1, 1, 1)

var _timer_turbo: float = 0.0
var ativo: bool = false
func _ready() -> void:
	fumaça.emitting = false
	# duplica o material pra essa fumaça ficar única por carro
	# (senão mudar a cor num carro mudaria em todos, ex: bots)
	if fumaça.process_material:
		fumaça.process_material = fumaça.process_material.duplicate()


func ativar(cor: Color = COR_PADRAO) -> void:
	_timer_turbo = duracao_turbo
	ativo = true
	fumaça.emitting = true
	if fumaça.process_material:
		fumaça.process_material.color = cor

func tick(delta: float) -> void:
	if ativo:
		_timer_turbo -= delta
		movimento_componente.velocidade_turbo = forca_turbo
		if _timer_turbo <= 0.0:
			ativo = false
			fumaça.emitting = false
			movimento_componente.velocidade_turbo = 0.0
			if fumaça.process_material:
				fumaça.process_material.color = COR_PADRAO
