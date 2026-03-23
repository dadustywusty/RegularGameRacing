extends SpringArm3D
class_name CameraComponente

# configurações ajustáveis pelo Inspector
@export var suavidade: float = 30 #quanto maior menos suave
@export var distancia_min: float = 7.7  # distância quando parado
@export var distancia_max: float = 8.0  # distância máxima em alta velocidade
@export var velocidade_max: float = 10.0  # velocidade de referência para os calculos
@export var fov_min: float = 60.0  # fov quando parado
@export var fov_max: float = 62.0  # fov em alta velocidade
@export var altura: float = 2  # altura do pivot acima do carro

var _alvo_posicao: Vector3
var _camera: Camera3D
var retrovisor := false

func _ready() -> void:
	
	top_level = true
	_alvo_posicao = global_position
	# pega a Camera3D que é filha do SpringArm3D
	_camera = get_child(0)

func tick(delta: float, velocidade: float) -> void:
	var pai = get_parent()
	# t vai de 0 (parado) até 1 (velocidade máxima)
	var t = clamp(abs(velocidade) / velocidade_max, 0.0, 1.0)
	var angulo_alvo = pai.global_rotation.y
	
	if retrovisor:
		angulo_alvo += PI
	
	# suaviza a rotação Y para seguir a direção do carro
	global_rotation.y = lerp_angle(global_rotation.y, angulo_alvo, suavidade * delta)
	
	# suaviza a posição seguindo o carro com um offset de altura
	_alvo_posicao = pai.global_position + Vector3.UP * altura
	global_position = global_position.lerp(_alvo_posicao, suavidade * delta)
	
	# afasta a câmera conforme a velocidade aumenta
	var distancia_alvo = lerp(distancia_min, distancia_max, t)
	spring_length = lerp(spring_length, distancia_alvo, 3.0 * delta)
	
	# aumenta o FOV conforme a velocidade — dá sensação de movimento
	if _camera:
		_camera.fov = lerp(_camera.fov, lerp(fov_min, fov_max, t), 5.0 * delta)
