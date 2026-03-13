extends Node
class_name MovimentoComponente

# esse script lida APENAS com movimento, ele não lê input

@export var corpo : CharacterBody3D

var velocidade := 40.0
var angulo := 15
# esse parametro é o mesmo da aceleração do inputcomponente
var aceleracao := 0.0
# mesma coisa do de cima
var rotacao := 0.0

func tick(delta: float) -> void:
	# ignora o script se nao tiver carro, impedindo o jogo de crashar
	if corpo == null:
		return
	# move o carro pra frente
	corpo.velocity = corpo.global_basis.z * (aceleracao * velocidade)
	# gira o carro
	rotacao *= deg_to_rad(angulo)
	# se vc descobrir como e por que esse codigo funciona e gira o carro pfv
	# me explica eu quase chorei tentando fazer sozinho usando 
	# corpo.rotation.y = angulo * rotacao mas nao tava funfando ate eu desistir
	# e copiar o tutorial.
	# da pra perceber que eu to perdendo a cabeça?
	# tipo assim o que CARALHOS é um slerp porra???????
	var base = corpo.global_basis.rotated(corpo.global_basis.y, rotacao)
	corpo.global_basis = corpo.global_basis.slerp(base, angulo * delta)
	corpo.global_basis = corpo.global_basis.orthonormalized()
	
	corpo.move_and_slide()
