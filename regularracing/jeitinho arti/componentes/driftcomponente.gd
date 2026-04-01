extends Node
class_name DriftComponente

@export var corpo: CharacterBody3D
@onready var turbo: TurboComponente = $"../turbo"

@export var tempo_nivel_1: float = 1.0
@export var tempo_nivel_2: float = 2.0
@export var tempo_nivel_3: float = 4.0
@export var som_drift: AudioStreamPlayer3D
@export var pitch_nivel_1: float = 0.5
@export var pitch_nivel_2: float = 1.0
@export var pitch_nivel_3: float = 1.5

# ângulo base da curva
@export var angulo_base: float = 0.08
# quanto a curva fecha/abre ao pressionar direção
@export var angulo_fechado: float = 0.14  # mais fechado
@export var angulo_aberto: float = 0.07  # mais aberto
# velocidade de transição da curva
@export var velocidade_curva: float = 3.0

@export var angulo_minimo: float = 0.02

var _timer_drift: float = 0.0
var _nivel_atual: int = 0
var pegou_direcao := false
var direcao: float        # direção do drift (-1 ou 1)
var angulo_atual: float   # ângulo atual da curva
var drift := false
var input_direcao: float  # input atual do jogador

func tick(delta: float) -> void:
	if drift:
		if corpo.velocity.length() < 0.5:
			cancelar_drift_sem_turbo()
			return

		# calcula o ângulo alvo baseado no input
		var angulo_alvo: float
		if input_direcao == 0.0:
			# sem input: curva normal
			angulo_alvo = angulo_base * sign(direcao)
			angulo_atual = lerp(angulo_atual, angulo_alvo, velocidade_curva * delta)
			angulo_atual = clamp(angulo_atual, -angulo_fechado, -angulo_minimo) if direcao < 0 else clamp(angulo_atual, angulo_minimo, angulo_fechado)
		elif sign(input_direcao) == sign(direcao):
			# mesma direção do drift: curva mais fechada
			angulo_alvo = angulo_fechado * sign(direcao)
		else:
			# direção oposta: curva mais aberta
			angulo_alvo = angulo_aberto * sign(direcao)

		# suaviza a transição entre curvas
		angulo_atual = lerp(angulo_atual, angulo_alvo, velocidade_curva * delta)

		# aplica a rotação com o ângulo atual
		var base = corpo.global_basis.rotated(corpo.global_basis.y, angulo_atual)
		corpo.global_basis = corpo.global_basis.slerp(base, 10 * delta)
		corpo.global_basis = corpo.global_basis.orthonormalized()

		# quanto mais fechada a curva, mais rápido carrega
		# normaliza entre 0 e 1 onde 1 = mais fechado
		var fator_curva = clamp(abs(angulo_atual) / angulo_fechado, 0.0, 1.0)
		_timer_drift += delta * fator_curva

		var nivel_novo = _calcular_nivel()
		if nivel_novo != _nivel_atual:
			_nivel_atual = nivel_novo
			_tocar_som(_nivel_atual)

func comecar_drift() -> void:
	if not pegou_direcao:
		if input_direcao > 0:
			direcao = 1.0
			angulo_atual = angulo_base
			pegou_direcao = true
			drift = true
		elif input_direcao < 0:
			direcao = -1.0
			angulo_atual = -angulo_base
			pegou_direcao = true
			drift = true
		else:
			drift = false
			pegou_direcao = true

func terminar_drift() -> void:
	if drift and _nivel_atual >= 1:
		_ativar_turbo(_nivel_atual)
	drift = false
	pegou_direcao = false
	_timer_drift = 0.0
	_nivel_atual = 0
	angulo_atual = 0.0

func cancelar_drift_sem_turbo() -> void:
	drift = false
	pegou_direcao = false
	_timer_drift = 0.0
	_nivel_atual = 0
	angulo_atual = 0.0

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
