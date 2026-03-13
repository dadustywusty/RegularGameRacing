extends Node3D

@onready var ball = $monobola        # RigidBody3D que faz a física do carro
@onready var car_mesh = $carro       # Mesh visual do carro (sem física)
@onready var ground_ray = $RayCast3D # Detecta se o carro está no chão
@onready var spring_arm = $SpringArm3D # Braço da câmera, evita atravessar paredes, importante no futuro

# Câmera
var camera_lerp = 5.0 # Suavidade da câmera ao seguir o carro (maior = mais rápido)

# Posição do mesh do carro relativa à bola, pra fazer o carro mesher
var offset_bola = Vector3(0, -0.1, 0)

# configurações de movimento, provalvelmente a gente só vai copiar e colar o codigo e mudar uma coisa ali e aqui
#pro outros corredores. por isso eu mudei o nome
var aceleracao = 50.0      # força aplicada pra frente/trás
var angulo_virada = 21.0   # angulo máximo de virada em graus
var velocidade_de_viro = 5.0 # suavidade da virada (maior = mais brusco)
var limite_virar = 0.75    # velocidade mínima da bola pra permitir virar

# estado atual do input, Roraima, ou solido, ou nulo sla
var velocidade = 0.0
var rotacao = 0.0

func _ready():
	ground_ray.add_exception(ball)              # RayCast ignora a própria bola
	$SpringArm3D.add_excluded_object(ball)      # câmera ignora a própria bola
	car_mesh.rotation.y = deg_to_rad(180)       # corrige orientação inicial do mesh

func _physics_process(delta):
	# mantém o mesh do carro colado na posição da bola
	car_mesh.transform.origin = ball.transform.origin + offset_bola

	if ground_ray.is_colliding():
		# no chão: lê input normalmente
		velocidade = 0.0
		velocidade += Input.get_action_strength("accelerate")
		velocidade -= Input.get_action_strength("brake")
		velocidade *= aceleracao

		rotacao = 0.0
		rotacao += Input.get_action_strength("wheel-front-left")
		rotacao -= Input.get_action_strength("wheel-front-right")
		rotacao *= deg_to_rad(angulo_virada)
	else:
		# no ar: sem controle, pq isso é um jogo de carro, não de planadores
		velocidade = 0.0
		rotacao = 0.0

	# empurra a bola na direção que o carro aponta, o que é bom
	ball.apply_central_force(-car_mesh.global_transform.basis.z * velocidade)

	# vira o carro suavemente, só se tiver velocidade suficiente, igual vida real
	if ball.linear_velocity.length() > limite_virar:
		var new_basis = car_mesh.global_transform.basis.rotated(
			car_mesh.global_transform.basis.y,
			rotacao
		)
		# interpolação suave entre a rotação atual e a nova
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(
			new_basis,
			velocidade_de_viro * delta
		)
		# corrige distorções na matriz de transformação causadas pelo slerp
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()

	# câmera segue a posição da bola
	spring_arm.global_position = ball.global_position
	# câmera rotaciona suavemente acompanhando a direção do carro
	var target_rotation = car_mesh.global_transform.basis.get_euler()
	spring_arm.rotation.y = lerp_angle(spring_arm.rotation.y, target_rotation.y, camera_lerp * delta)
