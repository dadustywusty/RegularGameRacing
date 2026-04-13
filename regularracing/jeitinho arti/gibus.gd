extends CharacterBody3D

class_name Player
@onready var som_item: AudioStreamPlayer = $SomRoleta
@onready var som_item_aparece: AudioStreamPlayer = $som_item

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
@onready var peixe: Node3D = $"carro(1)/sedan/peixe"
@onready var roda_esquerda = $"carro(1)/sedan/wheel-front-left"
@onready var roda_direita = $"carro(1)/sedan/wheel-front-right"
@export var inclinacao_max: float = 16.0
@export var velocidade_inclinacao: float = 8.0
@export var velocidade_minima_drift := 1.0

var tem_item := false
var pegou_direcao_particula := false
var direcao_particula : float
var _rotacao_base_peixe: Vector3
var aceleracao := 0.0
var rotacao := 0.0
var drift : bool
var pulo : bool
var retrovisor : bool
var item_input : bool
var _levando_dano := false

func _ready() -> void:
	_rotacao_base_peixe = peixe.rotation

func receber_item(item) -> void:
	add_child(item)
	item.configurar(self)
	item_componente.tem_item = true
	item_componente.item_atual = item
	if som_item.playing:       # <-- só para se estiver tocando
		som_item.stop()
	som_item_aparece.play()

func levar_dano(direcao_empurrao: Vector3 = Vector3.ZERO) -> void:
	if _levando_dano:
		return
	_levando_dano = true

	if direcao_empurrao != Vector3.ZERO:
		velocity += direcao_empurrao * 20.0
	else:
		var dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		velocity += dir * 20.0

	var tween = create_tween()
	tween.tween_property($"carro(1)", "rotation:y", deg_to_rad(360.0), 0.6)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property($"carro(1)", "rotation:z", deg_to_rad(20.0), 0.3)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property($"carro(1)", "rotation:z", 0.0, 0.3)\
		.set_ease(Tween.EASE_IN)
	await tween.finished

	$"carro(1)".rotation.y = 0.0
	_levando_dano = false

func _physics_process(delta: float) -> void:
	if _levando_dano:
		velocity.x = lerp(velocity.x, 0.0, 0.03)
		velocity.z = lerp(velocity.z, 0.0, 0.03)
		velocity.y = fisica.velocidade_vertical
		fisica.no_chao = is_on_floor()
		fisica.tick(delta)
		camera.tick(delta, velocity.length())
		move_and_slide()
		return

	movimento_componente.tick(delta)
	drift_componente.tick(delta)
	fisica.no_chao = is_on_floor()
	fisica.tick(delta)
	camera.tick(delta, velocity.length())
	rotacao_componente.tick(delta)
	turbo.tick(delta)
	trick_componente.tick()
	item_componente.tick()

	var inclinacao_alvo = rotacao * deg_to_rad(inclinacao_max)
	peixe.rotation.z = lerp(peixe.rotation.z, _rotacao_base_peixe.z + inclinacao_alvo, velocidade_inclinacao * delta)

	if not is_on_floor():
		movimento_componente.aceleracao = 0
	else:
		movimento_componente.aceleracao = aceleracao

	if not movimento_componente.aceleracao == 0 or drift_componente.drift:
		movimento_componente.rotacao = rotacao

	if drift:
		if -global_basis.z.dot(velocity) > velocidade_minima_drift:
			drift_componente.comecar_drift()
	else:
		drift_componente.terminar_drift()
	drift_componente.input_direcao = rotacao

	velocity.y = fisica.velocidade_vertical
	item_componente.item_input = item_input
	tem_item = item_componente.tem_item

	if trick_componente.pode_trick and pulo:
		trick_componente.fazer_trick()

	som_motor.pitch_scale = remap(velocity.length(), 0, 100, 1.0, 3.0)

	if retrovisor:
		camera.retrovisor = true
	else:
		camera.retrovisor = false

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

	velocity.y = fisica.velocidade_vertical
	var direcao_frente = -global_transform.basis.z

	velocity = drift_componente.calcular_velocidade_drift(
		velocity,
		direcao_frente,
		velocity.length(),
		delta
	)

	move_and_slide()
