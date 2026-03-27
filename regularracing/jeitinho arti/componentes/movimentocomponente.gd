extends Node
class_name MovimentoComponente

# esse script lida APENAS com movimento, ele não lê input

@export var corpo : CharacterBody3D

var velocidade := 70.0
var angulo := 9
var velocidade_turbo: float = 0.0

# esse parametro é o mesmo da aceleração do inputcomponente
var aceleracao := 0.0
# mesma coisa do de cima
var rotacao := 0.0
# velocidade em que o carro para/começa a andar
var friccao := 4.0

var grip := 8.0

func tick(delta: float) -> void:
	if corpo == null:
		return
	
	var normal = corpo.get_floor_normal() if corpo.is_on_floor() else Vector3.UP
	var frente := -corpo.global_basis.z
	frente = (frente - normal * frente.dot(normal))#.normalized()
	var direita := corpo.global_basis.x
	
	var forca_atual := (aceleracao * velocidade) + velocidade_turbo
	var velocidade_alvo := frente * forca_atual
	
	var vel_plana = corpo.velocity.slide(normal)
	var vel_frente = frente * vel_plana.dot(frente)
	var vel_lateral = direita * vel_plana.dot(direita)
	vel_lateral = vel_lateral.lerp(Vector3.ZERO, grip * delta)
	
	var vel_final = vel_frente + vel_lateral
	corpo.velocity = vel_final
	
	if aceleracao != 0 or velocidade_turbo != 0:
		vel_final = vel_final.lerp(velocidade_alvo, friccao * delta)
	else:
		var f = friccao if corpo.is_on_floor() else 0.5
		var stop_vel = Vector3(0, corpo.velocity.y, 0)
		vel_final = vel_final.lerp(stop_vel, f * delta)
	
	corpo.velocity.x = vel_final.x
	corpo.velocity.z = vel_final.z
	
	rotacao *= deg_to_rad(angulo)
	var base = corpo.global_basis.rotated(corpo.global_basis.y, rotacao)
	corpo.global_basis = corpo.global_basis.slerp(base, angulo * delta)
	corpo.global_basis = corpo.global_basis.orthonormalized()
