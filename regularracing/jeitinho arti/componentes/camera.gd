extends SpringArm3D
class_name CameraComponente

# --- Configurações Originais ---
@export var suavidade: float = 30 
@export var distancia_min: float = 7.7
@export var distancia_max: float = 8.0
@export var velocidade_max: float = 10.0
@export var fov_min: float = 60.0
@export var fov_max: float = 62.0
@export var altura: float = 2

# --- Novas Configurações para o Drift ---
@export var angulo_drift: float = 0.25 # O quanto a câmera "sai" de lado (em radianos)
@export var suavidade_drift: float = 3.0 # Velocidade da transição da câmera no drift

var _alvo_posicao: Vector3
var _camera: Camera3D
var retrovisor := false

func _ready() -> void:
	top_level = true
	_alvo_posicao = global_position
	_camera = get_child(0)

# 'esta_no_drift' e 'direcao_drift' como argumentos
func tick(delta: float, velocidade: float, esta_no_drift: bool = false, direcao_drift: float = 0.0) -> void:
	var pai = get_parent()
	var t = clamp(abs(velocidade) / velocidade_max, 0.0, 1.0)
	
	# Lógica do Ângulo Base
	var angulo_alvo = pai.global_rotation.y
	
	# Efeito de Câmera de Lado (Drift)
	# Se estiver em drift, adicionamos um deslocamento angular oposto à direção, bem massa
	if esta_no_drift:
		# direcao_drift é 1 ou -1. Multiplicamos para a câmera "abrir" a visão
		angulo_alvo -= direcao_drift * angulo_drift
	
	if retrovisor:
		angulo_alvo += PI
	
	# Suavização da Rotação
	# Usamos uma suavidade menor no drift para a câmera parecer mais "pesada"
	var suavidade_atual = suavidade_drift if esta_no_drift else suavidade
	global_rotation.y = lerp_angle(global_rotation.y, angulo_alvo, suavidade_atual * delta)
	
	# 3. Posição (Seguindo o carro)
	_alvo_posicao = pai.global_position + Vector3.UP * altura
	global_position = global_position.lerp(_alvo_posicao, suavidade * delta)
	
	# 4. Distância e FOV
	var distancia_alvo = lerp(distancia_min, distancia_max, t)
	# No drift, podemos afastar um pouquinho mais a câmera
	if esta_no_drift:
		distancia_alvo += 0.5
		
	spring_length = lerp(spring_length, distancia_alvo, 3.0 * delta)
	
	if _camera:
		# FOV aumenta no drift para dar sensação de velocidade lateral
		var fov_adicional = 5.0 if esta_no_drift else 0.0
		var fov_final = lerp(fov_min, fov_max, t) + fov_adicional
		_camera.fov = lerp(_camera.fov, fov_final, 5.0 * delta)
