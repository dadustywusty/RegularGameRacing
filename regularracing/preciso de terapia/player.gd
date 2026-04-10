extends Node3D

# Referências aos nodes da cena
@onready var ball = $monobola        # RigidBody3D que faz a física do carro
@onready var car_mesh = $carro       # Mesh visual do carro (sem física)
@onready var ground_ray = $RayCast3D # Detecta se o carro está no chão
@onready var spring_arm = $SpringArm3D # Braço da câmera, evita atravessar paredes

# Câmera
var camera_lerp = 5.0 # Suavidade da câmera ao seguir o carro (maior = mais rápido)

# Posição do mesh do carro relativa à bola
var offset_bola = Vector3(0, -0.1, 0)

# Configurações de movimento
var aceleracao = 50.0      # Força aplicada pra frente/trás
var angulo_virada = 21.0   # Ângulo máximo de virada em graus
var velocidade_de_viro = 5.0 # Suavidade da virada (maior = mais brusco)
var limite_virar = 0.75    # Velocidade mínima da bola pra permitir virar

# Estado atual do input
var velocidade = 0.0
var rotacao = 0.0

func _ready():
	ground_ray.add_exception(ball)              # RayCast ignora a própria bola
	$SpringArm3D.add_excluded_object(ball)      # Câmera ignora a própria bola
	car_mesh.rotation.y = deg_to_rad(180)       # Corrige orientação inicial do mesh

func _physics_process(delta):
	# Mantém o mesh do carro colado na posição da bola
	car_mesh.transform.origin = ball.transform.origin + offset_bola

	if ground_ray.is_colliding():
		# No chão: lê input normalmente
		velocidade = 0.0
		velocidade += Input.get_action_strength("accelerate")
		velocidade -= Input.get_action_strength("brake")
		velocidade *= aceleracao

		rotacao = 0.0
		rotacao += Input.get_action_strength("wheel-front-left")
		rotacao -= Input.get_action_strength("wheel-front-right")
		rotacao *= deg_to_rad(angulo_virada)
	else:
		# No ar: sem controle
		velocidade = 0.0
		rotacao = 0.0

	# Empurra a bola na direção que o carro aponta
	ball.apply_central_force(-car_mesh.global_transform.basis.z * velocidade)

	# Vira o carro suavemente, só se tiver velocidade suficiente
	if ball.linear_velocity.length() > limite_virar:
		var new_basis = car_mesh.global_transform.basis.rotated(
			car_mesh.global_transform.basis.y,
			rotacao
		)
		# Interpolação suave entre a rotação atual e a nova
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(
			new_basis,
			velocidade_de_viro * delta
		)
		# Corrige distorções na matriz de transformação causadas pelo slerp
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()

	# Câmera segue a posição da bola
	spring_arm.global_position = ball.global_position
	# Câmera rotaciona suavemente acompanhando a direção do carro
	var target_rotation = car_mesh.global_transform.basis.get_euler()
	spring_arm.rotation.y = lerp_angle(spring_arm.rotation.y, target_rotation.y, camera_lerp * delta)
