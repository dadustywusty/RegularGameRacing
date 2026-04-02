extends Node
class_name MovimentoComponente

# esse script lida APENAS com movimento, ele não lê input
@onready var carro: Node3D = $".."
@export var corpo : RigidBody3D

var velocidade := 300.0
var angulo := 8
var velocidade_turbo: float = 0.0

# esse parametro é o mesmo da aceleração do inputcomponente
var aceleracao := 0.0
# mesma coisa do de cima
var rotacao := 0.0

func tick(delta: float) -> void:
	# ignora o script se nao tiver carro, impedindo o jogo de crashar
	if corpo == null:
		return
	
	var forca_atual := (aceleracao * velocidade) + velocidade_turbo
	
	if corpo.no_chao:
		corpo.apply_central_force(-carro.global_transform.basis.z * forca_atual)
	
	rotacao *= deg_to_rad(angulo)
	var base = corpo.global_basis.rotated(corpo.global_basis.y, rotacao)
	corpo.global_basis = corpo.global_basis.slerp(base, angulo * delta)
	corpo.global_basis = corpo.global_basis.orthonormalized()
