extends Node3D

@onready var ball = $monobola
@onready var car_mesh = $carro
@onready var ground_ray = $RayCast3D
@onready var spring_arm = $SpringArm3D

var camera_lerp = 5.0
var offset_bola = Vector3(0, -0.1, 0)
var aceleracao = 50.0
var angulo_virada = 21.0
var velocidade_de_viro = 5.0
var limite_virar = 0.75

var velocidade = 0.0
var rotacao = 0.0

func _ready():
	ground_ray.add_exception(ball)
	$SpringArm3D.add_excluded_object(ball)
	# Rotaciona o carro 180 graus no eixo Y na inicialização
	car_mesh.rotation.y = deg_to_rad(180)

func _physics_process(delta):
	car_mesh.transform.origin = ball.transform.origin + offset_bola

	# DEBUG - mostra no console o que está acontecendo
	print("RayCast colidindo: ", ground_ray.is_colliding())
	print("Velocidade da bola: ", ball.linear_velocity.length())
	print("Accelerate pressionado: ", Input.get_action_strength("accelerate"))
	
	if ground_ray.is_colliding():
		velocidade = 0.0
		velocidade += Input.get_action_strength("accelerate")
		velocidade -= Input.get_action_strength("brake")
		velocidade *= aceleracao
		rotacao = 0.0
		rotacao += Input.get_action_strength("wheel-front-left")
		rotacao -= Input.get_action_strength("wheel-front-right")
		rotacao *= deg_to_rad(angulo_virada)
	else:
		velocidade = 0.0
		rotacao = 0.0

	ball.apply_central_force(-car_mesh.global_transform.basis.z * velocidade)

	# Vira o carro
	if ball.linear_velocity.length() > limite_virar:
		var new_basis = car_mesh.global_transform.basis.rotated(
			car_mesh.global_transform.basis.y,
			rotacao
		)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(
			new_basis,
			velocidade_de_viro * delta
		)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()

	# --- CÂMERA ---
	spring_arm.global_position = ball.global_position
	var target_rotation = car_mesh.global_transform.basis.get_euler()
	spring_arm.rotation.y = lerp_angle(spring_arm.rotation.y, target_rotation.y, camera_lerp * delta)
