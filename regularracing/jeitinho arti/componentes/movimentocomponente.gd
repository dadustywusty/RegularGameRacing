extends Node
class_name MovimentoComponente

# esse script lida APENAS com movimento, ele não lê input

@export var corpo : CharacterBody3D

var velocidade := 30.0
var angulo := 8
var velocidade_turbo: float = 0.0

# esse parametro é o mesmo da aceleração do inputcomponente
var aceleracao := 0.0
# mesma coisa do de cima
var rotacao := 0.0
# velocidade em que o carro para/começa a andar
var friccao := 4.0

func tick(delta: float) -> void:
	# ignora o script se nao tiver carro, impedindo o jogo de crashar
	if corpo == null:
		return
	
	var direcao_alvo := -corpo.global_basis.z
	var forca_atual := (aceleracao * velocidade) + velocidade_turbo
	var velocidade_alvo := direcao_alvo * forca_atual
	
	if aceleracao != 0 or velocidade_turbo != 0:
		corpo.velocity = corpo.velocity.lerp(velocidade_alvo, friccao * delta)
	else:
		var nova_friccao = friccao if corpo.is_on_floor() else 0.5
		corpo.velocity = corpo.velocity.lerp(Vector3.ZERO, nova_friccao * delta)
	
	rotacao *= deg_to_rad(angulo)
	var base = corpo.global_basis.rotated(corpo.global_basis.y, rotacao)
	corpo.global_basis = corpo.global_basis.slerp(base, angulo * delta)
	corpo.global_basis = corpo.global_basis.orthonormalized()
