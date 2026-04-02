extends Node
class_name DriftComponente

# ─── Referências ───────────────────────────────────────────
@export var corpo: CharacterBody3D
@export var modelo: Node3D
@onready var turbo: TurboComponente = $"../turbo"

# ─── Som ───────────────────────────────────────────────────
@export var som_drift: AudioStreamPlayer3D
@export var pitch_nivel_1: float = 0.5
@export var pitch_nivel_2: float = 1.0
@export var pitch_nivel_3: float = 1.5

# ─── Níveis ────────────────────────────────────────────────
@export var tempo_nivel_1: float = 1.0
@export var tempo_nivel_2: float = 2.0
@export var tempo_nivel_3: float = 4.0

# ─── Curva do drift ────────────────────────────────────────
@export var angulo_fechado: float = 0.14  # input na mesma direção
@export var angulo_base: float = 0.08     # sem input
@export var angulo_aberto: float = 0.1   # input oposto — FIXO, nunca passa disso, se passar quebra o drift
@export var velocidade_curva: float = 3.0

# ─── Modelo ────────────────────────────────────────────────
@export var inclinacao_drift: float = 12.0     # graus de inclinação no drift
@export var inclinacao_direcao: float = 6.0    # graus extras ao pressionar direção
@export var velocidade_inclinacao: float = 6.0

# ─── Estado interno ────────────────────────────────────────
var _timer_drift: float = 0.0
var _nivel_atual: int = 0
var _rotacao_base_modelo: Vector3

var pegou_direcao: bool = false
var direcao: float = 0.0
var angulo_atual: float = 0.0
var drift: bool = false
var input_direcao: float = 0.0

# ───────────────────────────────────────────────────────────

func _ready() -> void:
	if modelo:
		_rotacao_base_modelo = modelo.rotation

func tick(delta: float) -> void:
	if not drift:
		return
	if corpo.velocity.length() < 0.5:
		cancelar_drift_sem_turbo()
		return
	_atualizar_angulo(delta)
	_atualizar_modelo(delta)
	_aplicar_rotacao(delta)
	_atualizar_timer(delta)

func comecar_drift() -> void:
	if pegou_direcao:
		return
	if input_direcao > 0:
		direcao = 1.0
		angulo_atual = angulo_base
		drift = true
	elif input_direcao < 0:
		direcao = -1.0
		angulo_atual = -angulo_base
		drift = true
	pegou_direcao = true

func terminar_drift() -> void:
	if drift and _nivel_atual >= 1:
		_ativar_turbo(_nivel_atual)
	_resetar()

func cancelar_drift_sem_turbo() -> void:
	_resetar()

# ─── Privadas ──────────────────────────────────────────────

func _atualizar_angulo(delta: float) -> void:
	var angulo_alvo: float
	if input_direcao == 0.0:
		angulo_alvo = angulo_base * sign(direcao)
	elif sign(input_direcao) == sign(direcao):
		angulo_alvo = angulo_fechado * sign(direcao)
	else:
		# direção oposta: vai para angulo_aberto e PARA — não passa disso
		angulo_alvo = angulo_aberto * sign(direcao)

	angulo_atual = lerp(angulo_atual, angulo_alvo, velocidade_curva * delta)

	# clamp rígido — nunca ultrapassa o aberto nem o fechado
	if direcao > 0:
		angulo_atual = clamp(angulo_atual, angulo_aberto, angulo_fechado)
	else:
		angulo_atual = clamp(angulo_atual, -angulo_fechado, -angulo_aberto)

func _atualizar_modelo(delta: float) -> void:
	if not modelo:
		return

	# inclinação base do drift + extra dependendo do input
	var inclinacao_alvo = _rotacao_base_modelo.z
	
	if drift:
		# inclina para o lado do drift
		var extra = 0.0
		if sign(input_direcao) == sign(direcao):
			# mesma direção: inclina mais
			extra = deg_to_rad(inclinacao_direcao)
		elif input_direcao != 0.0:
			# direção oposta: inclina menos
			extra = -deg_to_rad(inclinacao_direcao * 0.5)

		inclinacao_alvo = _rotacao_base_modelo.z + deg_to_rad(-sign(direcao) * inclinacao_drift) + extra * -sign(direcao)

	modelo.rotation.z = lerp(modelo.rotation.z, inclinacao_alvo, velocidade_inclinacao * delta)

func _aplicar_rotacao(delta: float) -> void:
	var base = corpo.global_basis.rotated(corpo.global_basis.y, angulo_atual)
	corpo.global_basis = corpo.global_basis.slerp(base, 10 * delta)
	corpo.global_basis = corpo.global_basis.orthonormalized()

func _atualizar_timer(delta: float) -> void:
	var fator_curva = clamp(abs(angulo_atual) / angulo_fechado, 0.0, 1.0)
	_timer_drift += delta * fator_curva

	var nivel_novo = _calcular_nivel()
	if nivel_novo != _nivel_atual:
		_nivel_atual = nivel_novo
		_tocar_som(_nivel_atual)

func _resetar() -> void:
	drift = false
	pegou_direcao = false
	_timer_drift = 0.0
	_nivel_atual = 0
	angulo_atual = 0.0
	if modelo:
		var tween = modelo.create_tween()
		tween.tween_property(modelo, "rotation:z", _rotacao_base_modelo.z, 0.3)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_CUBIC)

func _calcular_nivel() -> int:
	if _timer_drift >= tempo_nivel_3:
		return 3
	elif _timer_drift >= tempo_nivel_2:
		return 2
	elif _timer_drift >= tempo_nivel_1:
		return 1
	return 0

func _tocar_som(nivel: int) -> void:
	if som_drift == null:
		return
	match nivel:
		1: som_drift.pitch_scale = pitch_nivel_1
		2: som_drift.pitch_scale = pitch_nivel_2
		3: som_drift.pitch_scale = pitch_nivel_3
	som_drift.play()

func _ativar_turbo(nivel: int) -> void:
	match nivel:
		1: turbo.forca_turbo = 30; turbo.duracao_turbo = 0.2
		2: turbo.forca_turbo = 70; turbo.duracao_turbo = 0.4
		3: turbo.forca_turbo = 100; turbo.duracao_turbo = 0.5
	turbo.ativar()
