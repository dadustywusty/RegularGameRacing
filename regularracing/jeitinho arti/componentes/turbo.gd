extends Node
class_name TurboComponente

@onready var movimento_componente: MovimentoComponente = %MovimentoComponente
@onready var fogo = $"../Node3D"
@export var forca_turbo: float
@export var duracao_turbo: float

var _timer_turbo: float = 0.0
var ativo: bool = false
func _ready() -> void:
	fogo.get_node("fogo").emitting = false


func ativar() -> void:
	_timer_turbo = duracao_turbo
	ativo = true
	fogo.get_node("fogo").emitting = true 

func tick(delta: float) -> void:
	if ativo:
		_timer_turbo -= delta
		movimento_componente.velocidade_turbo = forca_turbo
		if _timer_turbo <= 0.0:
			ativo = false
			fogo.get_node("fogo").emitting = false
			movimento_componente.velocidade_turbo = 0.0
