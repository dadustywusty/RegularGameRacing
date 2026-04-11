extends Node
class_name DriftComponente

# ─── Referências ───────────────────────────────────────────
@export var corpo: CharacterBody3D
@export var modelo: Node3D
@onready var turbo: TurboComponente = $"../turbo"

# ─── Física de Deslize (Tração/Sabão) ──────────────────────
@export_group("Física de Tração")
@export var tracao_normal: float = 10.0  # Resposta rápida (asfalto)
@export var tracao_drift: float = 1.5    # Efeito "sabão" (quanto menor, mais escorrega)
var tracao_atual: float = 10.0

# ─── Som ───────────────────────────────────────────────────
@export_group("Áudio")
@export var som_drift: AudioStreamPlayer3D
@export var pitch_nivel_1: float = 0.8
@export var pitch_nivel_2: float = 1.1
@export var pitch_nivel_3: float = 1.4

# ─── Níveis de Turbo ───────────────────────────────────────
@export_group("Níveis de Mini-Turbo")
@export var tempo_nivel_1: float = 0.8
@export var tempo_nivel_2: float = 1.6
@export var tempo_nivel_3: float = 3.0

# ─── Curva do drift ────────────────────────────────────────
@export_group("Ângulos de Curva")
@export var angulo_fechado: float = 0.2  # Analógico p/ o mesmo lado
@export var angulo_base: float = 0.08     # Sem input lateral
@export var angulo_aberto: float = 0.1675042069 # Analógico p/ o lado oposto (Counter-steer)
@export var velocidade_curva: float = 3.0

# ─── Estado Interno ────────────────────────────────────────
var _timer_drift: float = 0.0
var _nivel_atual: int = 0
var _rotacao_base_modelo: Vector3

var pegou_direcao: bool = false
var direcao: float = 0.0       # 1 p/ Direita, -1 p/ Esquerda
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
	
	# Cancela drift se o carro parar (bater na parede)
	if corpo.velocity.length() < 1.0:
		cancelar_drift_sem_turbo()
		return
		
	_atualizar_angulo(delta)
	
	_aplicar_rotacao(delta)
	_atualizar_timer(delta)

## Esta função deve ser chamada pelo script do Carro ANTES do move_and_slide
func calcular_velocidade_drift(velocidade_atual: Vector3, forward_vector: Vector3, velocidade_alvo: float, delta: float) -> Vector3:
	tracao_atual = tracao_drift if drift else tracao_normal
	
	# O LERP cria a inércia: a velocidade demora a seguir o nariz do carro
	var direcao_desejada = forward_vector * velocidade_alvo
	var nova_velocidade = velocidade_atual.lerp(direcao_desejada, tracao_atual * delta)
	
	nova_velocidade.y = velocidade_atual.y # Mantém gravidade
	return nova_velocidade

func comecar_drift() -> void:
	if pegou_direcao or abs(input_direcao) < 0.1:
		return
		
	direcao = sign(input_direcao)
	angulo_atual = angulo_base * direcao
	drift = true
	pegou_direcao = true

func terminar_drift() -> void:
	if drift and _nivel_atual >= 1:
		_ativar_turbo(_nivel_atual)
	_resetar()

func cancelar_drift_sem_turbo() -> void:
	_resetar()

# ─── Lógica Privada ────────────────────────────────────────

func _atualizar_angulo(delta: float) -> void:
	var angulo_alvo: float
	
	if input_direcao == 0.0:
		angulo_alvo = angulo_base * direcao
	elif sign(input_direcao) == direcao:
		angulo_alvo = angulo_fechado * direcao # Curva fechada (carrega turbo rápido)
	else:
		angulo_alvo = angulo_aberto * direcao  # Curva aberta (carrega turbo devagar)

	angulo_atual = lerp(angulo_atual, angulo_alvo, velocidade_curva * delta)


	

func _aplicar_rotacao(delta: float) -> void:
	# Gira a base do CharacterBody3D no eixo Y
	var base_nova = corpo.global_basis.rotated(corpo.global_basis.y, angulo_atual)
	corpo.global_basis = corpo.global_basis.slerp(base_nova, 10 * delta).orthonormalized()

func _atualizar_timer(delta: float) -> void:
	# "Soft Drift": Quanto mais fechada a curva, mais rápido o turbo carrega
	var fator_curva = clamp(abs(angulo_atual) / angulo_fechado, 0.3, 1.5)
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
		tween.tween_property(modelo, "rotation:z", _rotacao_base_modelo.z, 0.3).set_trans(Tween.TRANS_CUBIC)

func _calcular_nivel() -> int:
	if _timer_drift >= tempo_nivel_3: return 3
	if _timer_drift >= tempo_nivel_2: return 2
	if _timer_drift >= tempo_nivel_1: return 1
	return 0

func _tocar_som(nivel: int) -> void:
	if som_drift and nivel > 0:
		som_drift.pitch_scale = [0, pitch_nivel_1, pitch_nivel_2, pitch_nivel_3][nivel]
		som_drift.play()

func _ativar_turbo(nivel: int) -> void:
	# Valores baseados na sua lógica de TurboComponente
	match nivel:
		1: turbo.forca_turbo = 35; turbo.duracao_turbo = 0.3
		2: turbo.forca_turbo = 75; turbo.duracao_turbo = 0.6
		3: turbo.forca_turbo = 110; turbo.duracao_turbo = 1.0
	turbo.ativar()
