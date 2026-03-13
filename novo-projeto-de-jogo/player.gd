extends Node3D

@onready var ball = $monobola
@onready var car_mesh = $carro
@onready var ground_ray = $RayCast3D


var realocassao_bola = Vector3(0,-1.0, 0)
var acelerassal = 50 
var virada = 21.0 
var velocidade_de_viro = 5
var limite_virar = 0.75

var velocidade = 0 
var rotassao = 0

func _ready():
	ground_ray.add_exception(ball)

func _physics_process(_delta):
	car_mesh.transform.origin = ball.transform.origin + realocassao_bola
	ball.add_central_force(-car_mesh.global_transform.basis.z * velocidade)

func _process(_delta):
	if not ground_ray.is_colliding():
		return
		velocidade = 0
		velocidade += Input.get_action_strength("accelerate")
		velocidade -= Input.get_action_strength("brake")
		velocidade *= acelerassal
		rotassao = 0 
		rotassao += Input.get_action_strength("wheel-front-left")
		rotassao -= Input.get_action_strength("wheel-front-right")
		rotassao *= deg_to_rad(virada)
