extends CharacterBody3D

class_name PlayerTeste

@export var stats : Stats
@onready var friccao := stats.friccao
@onready var angulo_virada := stats.angulo_virada

@onready var input_componente : InputComponente = %InputComponente
@onready var movimento_componente : MovimentoComponente2 = %MovimentoComponente2
@onready var fisica_componente: FisicaComponente2 = %FisicaComponente2
@onready var rotacao_componente: RotacaoComponente = %RotacaoComponente
@onready var drift_componente: DriftComponente2 = %DriftComponente2

var aceleracao : float
var rotacao : float
var drift : bool
var pulo : bool
var item_input : bool
var retrovisor : bool

func _physics_process(delta: float) -> void:
	drift_componente.input_direcao = rotacao
	drift_componente.drift = drift
	if not drift:
		drift_componente.terminar_drift()
	drift_componente.tick(delta)
	
	movimento_componente.impulso = aceleracao
	movimento_componente.rotacao = drift_componente.filtrar_input(rotacao)
	movimento_componente.tick(delta)
	#rotacao_componente.tick(delta)
	#colisao_componente.tick(delta)
	
	fisica_componente.tick(delta)
	move_and_slide()
	fisica_componente.limpar()
