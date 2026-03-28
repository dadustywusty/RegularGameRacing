extends CharacterBody3D

@onready var input_componente: InputComponente = $InputComponente
@onready var movimento_componente: MovimentoComponente = $MovimentoComponente
@onready var drift_componente: DriftComponente = %DriftComponente
@onready var fisica = %fisica
@onready var camera: CameraComponente = $SpringArm3D
@onready var rotacao_componente: RotacaoComponente = %RotacaoComponente
@onready var turbo: TurboComponente = %turbo
@onready var som_motor: AudioStreamPlayer3D = $SomMotor
@onready var particula_drift_l: GPUParticles3D = $"carro(1)/ParticulaDriftL"
@onready var particula_drift_r: GPUParticles3D = $"carro(1)/ParticulaDriftR"
@onready var trick_componente: TrickComponente = %TrickComponente
@onready var item_componente: ItemComponente = %ItemComponente

@export var velocidade_minima_drift := 1.0

var tem_item := false
var pegou_direcao_particula := false
var direcao_particula : float

func receber_item(item) -> void:
	add_child(item)
	item.configurar(self)
	item_componente.tem_item = true
	item_componente.item_atual = item

func _physics_process(delta: float) -> void:
	input_componente.update()
	movimento_componente.tick(delta)
	drift_componente.tick(delta)
	fisica.no_chao = is_on_floor()
	fisica.tick(delta) 
	camera.tick(delta, velocity.length()) 
	rotacao_componente.tick(delta)
	turbo.tick(delta)
	item_componente.tick()
	
	# acelera o player
	if not is_on_floor():
		movimento_componente.aceleracao = 0
	else:
		movimento_componente.aceleracao = input_componente.aceleracao
	
	# gira o player
	if not movimento_componente.aceleracao == 0 or drift_componente.drift:
		movimento_componente.rotacao = input_componente.rotacao
	
	# começa e termina drift
	if input_componente.drift:
		if -global_basis.z.dot(velocity) > velocidade_minima_drift:
			drift_componente.comecar_drift()
	else: 
		drift_componente.terminar_drift()
	drift_componente.input_direcao = input_componente.rotacao
	
	# gravidade
	velocity.y = fisica.velocidade_vertical
	
	# lida com os itens
	tem_item = item_componente.tem_item
	
	# faz trick
	if trick_componente.pode_trick and Input.is_action_just_pressed("drift"):
		trick_componente.fez_trick = true
		trick_componente.trick()
		trick_componente.pode_trick = false
	
	# mexe o som do motor
	som_motor.pitch_scale = remap(velocity.length(), 0, 100, 1.0, 3.0)
	
	# aciona o retrovisor
	if Input.is_action_pressed("retrovisor"):
		camera.retrovisor = true
	else:
		camera.retrovisor = false
	
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
	
	move_and_slide()
