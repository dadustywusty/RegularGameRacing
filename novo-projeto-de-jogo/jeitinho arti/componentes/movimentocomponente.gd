extends Node
class_name MovimentoComponente

@export var corpo: CharacterBody3D
@export var grip_curve: Curve  # curva de aderência configurável no Inspector

var velocidade := 30.0
var angulo := 10
var velocidade_turbo: float = 0.0
var aceleracao := 0.0
var rotacao := 0.0
var friccao := 4.0
var em_drift: bool = false

func tick(delta: float) -> void:
	if corpo == null:
		return

	var direcao_frente = -corpo.global_basis.z
	var forca_atual = (aceleracao * velocidade) + velocidade_turbo
	var velocidade_alvo = direcao_frente * forca_atual
	var horizontal = corpo.velocity
	horizontal.y = 0

	# calcula o slip factor — quão desalinhada está a velocidade com a frente
	var slip_factor = 0.0
	if horizontal.length() > 0.1:
		slip_factor = 1.0 - clamp(direcao_frente.dot(horizontal.normalized()), 0.0, 1.0)

	# pega o grip da curva (0 = sem aderência, 1 = aderência total)
	var grip = 1.0
	if grip_curve:
		grip = grip_curve.sample(slip_factor)

	# em drift reduz o grip drasticamente
	if em_drift:
		grip = minf(grip, 0.15)

	if aceleracao != 0 or velocidade_turbo != 0:
		var fator = friccao * grip
		horizontal = horizontal.lerp(velocidade_alvo, fator * delta)
	else:
		var nova_friccao = friccao if corpo.is_on_floor() else 0.5
		horizontal = horizontal.lerp(Vector3.ZERO, nova_friccao * delta)

	corpo.velocity.x = horizontal.x
	corpo.velocity.z = horizontal.z

	rotacao *= deg_to_rad(angulo)
	var base = corpo.global_basis.rotated(corpo.global_basis.y, rotacao)
	corpo.global_basis = corpo.global_basis.slerp(base, angulo * delta)
	corpo.global_basis = corpo.global_basis.orthonormalized()
	corpo.move_and_slide()
