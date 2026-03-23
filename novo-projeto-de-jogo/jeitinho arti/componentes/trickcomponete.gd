extends Node
class_name TrickComponente

@export var corpo: CharacterBody3D
@export var modelo: Node3D  # arrasta o sedan aqui
@export var tempo_janela: float = 0.5   # janela de tempo para contar o trick
@export var tempo_animacao: float = 0.4 # tempo do giro
@export var tempo_minimo_ar: float = 0.3  # precisa ficar pelo menos 0.3s no ar

var _no_ar: bool = false
var _timer_no_ar: float = 0.0
var _trick_pendente: bool = false
var _animando: bool = false
var _rotacao_inicial: Vector3

func tick(delta: float) -> void:
	if corpo.is_on_floor():
		# acabou de pousar com trick pendente
		if _trick_pendente and not _animando:
			_executar_trick()
		_no_ar = false
		_timer_no_ar = 0.0
	else:
		_no_ar = true
		_timer_no_ar += delta
		# trick só conta se ficou pelo menos um pouco no ar
		if _timer_no_ar > 0.1:
			_trick_pendente = false

func tentar_trick() -> void:
	if _no_ar and _timer_no_ar >= tempo_minimo_ar:
		_trick_pendente = true

func _executar_trick() -> void:
	_trick_pendente = false
	_animando = true
	_rotacao_inicial = modelo.rotation

	# escolhe eixo aleatório: 0 = X, 1 = Y
	var eixo = randi() % 2
	var rotacao_alvo = modelo.rotation

	if eixo == 0:
		rotacao_alvo.x += TAU  # 360 graus em X
	else:
		rotacao_alvo.y += TAU  # 360 graus em Y

	var tween = modelo.create_tween()
	tween.tween_property(modelo, "rotation", rotacao_alvo, tempo_animacao)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_finalizar_trick)

func _finalizar_trick() -> void:
	# normaliza a rotação para não acumular infinitamente
	modelo.rotation.x = fmod(modelo.rotation.x, TAU)
	modelo.rotation.y = fmod(modelo.rotation.y, TAU)
	_animando = false
	
func parar_trick() -> void:
	if not _animando:
		return
	_animando = false
	var tween = modelo.create_tween()
	tween.tween_property(modelo, "rotation", _rotacao_base, 0.2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
