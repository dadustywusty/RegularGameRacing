extends Node
class_name DriftComponente

@onready var movimento_componente: MovimentoComponente = %MovimentoComponente

var angulo_base
var angulo_drift
var drift := false

func _ready() -> void:
	angulo_base = movimento_componente.angulo
	angulo_drift = movimento_componente.angulo * 2

func tick() -> void:
	if drift:
		movimento_componente.angulo = angulo_drift
	else:
		movimento_componente.angulo = angulo_base
