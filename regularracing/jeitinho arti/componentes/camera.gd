extends SpringArm3D
class_name CameraComponente

@export var suavidade: float = 30 
@export var distancia_min: float = 7.7
@export var distancia_max: float = 8.0
@export var velocidade_max: float = 10.0
@export var fov_min: float = 60.0
@export var fov_max: float = 62.0
@export var altura: float = 2
@export var angulo_drift: float = 0.25
@export var suavidade_drift: float = 3.0


@export var angulo_x_base: float = -0.2      # inclinação padrão (em radianos)
@export var angulo_x_drift: float = -0.25    # inclinação no drift
@export var suavidade_x: float = 0.5         # suavidade da inclinação vertical

var _alvo_posicao: Vector3
var _camera: Camera3D
var retrovisor := false

func _ready() -> void:
	top_level = true
	_alvo_posicao = global_position
	_camera = get_child(0)

func tick(delta: float, velocidade: float, esta_no_drift: bool = false, direcao_drift: float = 0.0) -> void:
	var pai = get_parent()
	var t = clamp(abs(velocidade) / velocidade_max, 0.0, 1.0)

	# Ângulo Y
	var angulo_alvo = pai.global_rotation.y
	if esta_no_drift:
		angulo_alvo -= direcao_drift * angulo_drift
	if retrovisor:
		angulo_alvo += PI

	var suavidade_atual = suavidade_drift if esta_no_drift else suavidade
	global_rotation.y = lerp_angle(global_rotation.y, angulo_alvo, suavidade_atual * delta)

	# Ângulo X suavizado
	var alvo_x = angulo_x_drift if esta_no_drift else angulo_x_base
	global_rotation.x = lerp_angle(global_rotation.x, alvo_x, suavidade_x * delta)

	# Posição
	_alvo_posicao = pai.global_position + Vector3.UP * altura
	global_position = global_position.lerp(_alvo_posicao, suavidade * delta)

	# Distância e FOV
	var distancia_alvo = lerp(distancia_min, distancia_max, t)
	if esta_no_drift:
		distancia_alvo += 0.5
	spring_length = lerp(spring_length, distancia_alvo, 3.0 * delta)

	if _camera:
		var fov_adicional = 5.0 if esta_no_drift else 0.0
		var fov_final = lerp(fov_min, fov_max, t) + fov_adicional
		_camera.fov = lerp(_camera.fov, fov_final, 5.0 * delta)
