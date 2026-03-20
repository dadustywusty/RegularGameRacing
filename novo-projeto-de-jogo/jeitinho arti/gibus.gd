extends CharacterBody3D

@onready var input_componente: InputComponente = $InputComponente
@onready var movimento_componente: MovimentoComponente = $MovimentoComponente
@onready var drift_componente: DriftComponente = %DriftComponente
@onready var fisica = %fisica
@onready var camera: CameraComponente = $SpringArm3D
@onready var rotacao_componente: RotacaoComponente = %RotacaoComponente
@onready var turbo: TurboComponente = $turbo
@onready var som_motor: AudioStreamPlayer3D = $SomMotor
@onready var particula_drift_l: GPUParticles3D = $ParticulaDriftL
@onready var particula_drift_r: GPUParticles3D = $ParticulaDriftR

@export var velocidade_minima_drift := 1.0

var pegou_direcao_particula := false
var direcao_particula : float

func _physics_process(delta: float) -> void:
	input_componente.update()
	movimento_componente.tick(delta)
	drift_componente.tick(delta)
	fisica.no_chao = is_on_floor()
	fisica.tick(delta) 
	camera.tick(delta, velocity.length()) 
	rotacao_componente.tick()
	turbo.tick(delta)
	
	if not is_on_floor():
		movimento_componente.aceleracao = 0
	else:
		movimento_componente.aceleracao = input_componente.aceleracao
	if not movimento_componente.aceleracao == 0 or drift_componente.drift:
		movimento_componente.rotacao = input_componente.rotacao
	
	if input_componente.drift:
		if -global_basis.z.dot(velocity) > velocidade_minima_drift:
			drift_componente.comecar_drift()
	else: 
		drift_componente.terminar_drift()
	
	velocity.y = fisica.velocidade_vertical
	move_and_slide()
	som_motor.pitch_scale = remap(velocity.length(), 0, 100, 1.0, 3.0)
	
	# codigo pras particulas
	if is_on_floor() and drift_componente.drift:
		if pegou_direcao_particula == false:
			if drift_componente.direcao > 0:
				direcao_particula = 1.0
			elif drift_componente.direcao < 0:
				direcao_particula = -1.0
			pegou_direcao_particula = true
		particula_drift_l.process_material.direction.x = direcao_particula
		particula_drift_r.process_material.direction.x = direcao_particula
		particula_drift_l.emitting = true
		particula_drift_r.emitting = true
		
	else:
		particula_drift_l.emitting = false
		particula_drift_r.emitting = false
		particula_drift_l.process_material = preload("uid://dics5v6my3q6")
		particula_drift_r.process_material = preload("uid://dics5v6my3q6")
		pegou_direcao_particula = false
	
	
	if drift_componente._nivel_atual == 1:
		particula_drift_l.process_material = preload("uid://737ou2jibrqe")
		particula_drift_r.process_material = preload("uid://737ou2jibrqe")
	elif drift_componente._nivel_atual == 2:
		particula_drift_l.process_material = preload("uid://vd1jfxuxby30")
		particula_drift_r.process_material = preload("uid://vd1jfxuxby30")
	elif drift_componente._nivel_atual == 3:
		particula_drift_l.process_material = preload("uid://grmdou6sd7u2")
		particula_drift_r.process_material = preload("uid://grmdou6sd7u2")
