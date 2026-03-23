extends Node

@export var state_inicial : State

var state_atual : State
var states : Dictionary = {}

func _ready() -> void:
	for i in get_children():
		if i is State:
			states[i.name.to_lower()] = i
			i.transicionou.connect(transicionou)
	if state_inicial:
		state_inicial.entrar()
		state_atual = state_inicial

func _process(delta: float) -> void:
	if state_atual:
		state_atual.update(delta)

func _physics_process(delta: float) -> void:
	if state_atual:
		state_atual.physics_update(delta)

func transicionou(state, novo_state_nome):
	if state != state_atual:
		return
	
	var novo_state = states.get(novo_state_nome.to_lower())
	if !novo_state:
		return
	
	if state_atual:
		state_atual.sair()
	
	novo_state.entrar()
	state_atual = novo_state
