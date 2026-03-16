extends CharacterBody3D

@onready var input_componente: InputComponente = $InputComponente
@onready var movimento_componente: MovimentoComponente = $MovimentoComponente
@onready var drift_componente: DriftComponente = %DriftComponente
@onready var fisica = %fisica
@onready var camera: CameraComponente = $SpringArm3D
@onready var rotacao_componente: RotacaoComponente = %RotacaoComponente
@onready var turbo: TurboComponente = $turbo

func _physics_process(delta: float) -> void:
	input_componente.update()
	movimento_componente.tick(delta)
	drift_componente.tick()
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
		drift_componente.drift = true
	else: 
		drift_componente.drift = false
	
	velocity.y = fisica.velocidade_vertical
	move_and_slide()
