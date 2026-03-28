extends Node
class_name DriftComponente

@export var corpo : CharacterBody3D
@onready var turbo: TurboComponente = $"../turbo"

@export var tempo_nivel_1: float = 1.0  # tempo para atingir nível 1
@export var tempo_nivel_2: float = 1.7  # tempo para atingir nível 2
@export var tempo_nivel_3: float = 3.0  # tempo para atingir nível 3
@export var som_drift: AudioStreamPlayer3D
@export var pitch_nivel_1: float = 0.5   # grave
@export var pitch_nivel_2: float = 1.0   # normal
@export var pitch_nivel_3: float = 1.5   # agudo

var _timer_drift: float = 0.0
var _nivel_atual: int = 0  # 0 = sem drift, 1, 2 ou 3
var pegou_direcao := false
var direcao : float
var angulo := 11
var drift := false

var timer_velocidade := 1.0
var input_direcao : float

func tick(delta) -> void:
	if drift:
		if corpo.velocity.length() < 0.5:
			cancelar_drift_sem_turbo()
			return
		
		var base = corpo.global_basis.rotated(corpo.global_basis.y, direcao)
		corpo.global_basis = corpo.global_basis.slerp(base, angulo * delta)
		corpo.global_basis = corpo.global_basis.orthonormalized()
		
		var cima = corpo.get_floor_normal() if corpo.is_on_floor() else Vector3.UP
		var direita = corpo.global_basis.x.project(cima).normalized()
		corpo.velocity += direita * direcao * 5.0
		
		if sign(input_direcao) == sign(direcao):
			timer_velocidade = 1.0
		else:
			timer_velocidade = 0.5
		
		_timer_drift += delta * timer_velocidade
		
		# verifica mudança de nível
		var nivel_novo = _calcular_nivel()
		if nivel_novo != _nivel_atual:
			_nivel_atual = nivel_novo
			_tocar_som(_nivel_atual)

func comecar_drift() -> void:
	if not pegou_direcao:
		if input_direcao > 0:
			direcao = 0.17453292519943
			pegou_direcao = true
			drift = true
		elif input_direcao < 0:
			direcao = -0.17453292519943
			pegou_direcao = true
			drift = true
		else:
			drift = false
			pegou_direcao = true

func terminar_drift() -> void:
	# aplica turbo
	if drift:
		if _nivel_atual >= 1:
			_ativar_turbo(_nivel_atual, _nivel_atual)
			_timer_drift = 0.0
			_nivel_atual = 0
	drift = false
	pegou_direcao = false
	_timer_drift = 0.0
	_nivel_atual = 0

func cancelar_drift_sem_turbo() -> void:
	drift = false
	pegou_direcao = false
	_timer_drift = 0.0
	_nivel_atual = 0

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

func _ativar_turbo(nivel: int, tempo: int) -> void:
	match nivel:
		1: turbo.forca_turbo = 40
		2: turbo.forca_turbo = 80
		3: turbo.forca_turbo = 120
	match tempo:
		1: turbo.duracao_turbo = 0.3
		2: turbo.duracao_turbo = 0.5
		3: turbo.duracao_turbo = 0.7
	turbo.ativar()
