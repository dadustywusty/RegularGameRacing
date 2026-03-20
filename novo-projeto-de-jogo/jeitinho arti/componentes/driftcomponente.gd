extends Node
class_name DriftComponente

@export var corpo : CharacterBody3D
@onready var movimento_componente: MovimentoComponente = %MovimentoComponente
@onready var turbo: TurboComponente = $"../turbo"

@export var tempo_nivel_1: float = 1.5  # tempo para atingir nível 1
@export var tempo_nivel_2: float = 2.5  # tempo para atingir nível 2
@export var tempo_nivel_3: float = 4.0  # tempo para atingir nível 3
@export var som_drift: AudioStreamPlayer3D
@export var pitch_nivel_1: float = 0.5   # grave
@export var pitch_nivel_2: float = 1.0   # normal
@export var pitch_nivel_3: float = 1.5   # agudo

var _timer_drift: float = 0.0
var _nivel_atual: int = 0  # 0 = sem drift, 1, 2 ou 3
var pegou_direcao := false
var direcao : float
var drift := false

func tick(delta) -> void:
	if drift:
		var base = corpo.global_basis.rotated(corpo.global_basis.y, direcao)
		corpo.global_basis = corpo.global_basis.slerp(base, 12 * delta)
		corpo.global_basis = corpo.global_basis.orthonormalized()
		
		_timer_drift += get_process_delta_time()
		
		# verifica mudança de nível
		var nivel_novo = _calcular_nivel()
		if nivel_novo != _nivel_atual:
			_nivel_atual = nivel_novo
			_tocar_som(_nivel_atual)



func comecar_drift() -> void:
	if not pegou_direcao:
		if movimento_componente.rotacao > 0:
			direcao = 0.17453292519943
		if movimento_componente.rotacao < 0:
			direcao = -0.17453292519943
		pegou_direcao = true
	drift = true

func terminar_drift() -> void:
	drift = false
	pegou_direcao = false
	# aplica turbo
	if _nivel_atual >= 1:
		_ativar_turbo(_nivel_atual)
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

func _ativar_turbo(nivel: int) -> void:
	match nivel:
		1: turbo.forca_turbo = 40
		2: turbo.forca_turbo = 80
		3: turbo.forca_turbo = 120
	turbo.ativar()
