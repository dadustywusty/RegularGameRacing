extends CharacterBody3D

@onready var input_componente: InputComponente = $InputComponente
@onready var movimento_componente: MovimentoComponente = $MovimentoComponente
@onready var drift_componente: DriftComponente = %DriftComponente

func _physics_process(delta: float) -> void:
	input_componente.update()
	movimento_componente.tick(delta)
	drift_componente.tick()
	
	movimento_componente.aceleracao = input_componente.aceleracao
	movimento_componente.rotacao = input_componente.rotacao
	
	if input_componente.drift:
		drift_componente.drift = true
	else: 
		drift_componente.drift = false
