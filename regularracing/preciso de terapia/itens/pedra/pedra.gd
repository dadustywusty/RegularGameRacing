extends RigidBody3D
const VELOCIDADE := 100.0
var pai: Node3D
var corpo: CharacterBody3D
var usos := 1
var _ativa := false
var _animando := false
var _direcao := Vector3.ZERO
@onready var modelo: Node3D = $preda
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var som_rebate: AudioStreamPlayer3D = $SomRebate
@onready var som_rolando: AudioStreamPlayer3D = $SomRolando
func configurar(player: CharacterBody3D) -> void:
	corpo = player
	pai = player.get_parent()
	freeze = true
	contact_monitor = true
	max_contacts_reported = 4
	anim.stop()
	add_collision_exception_with(player)
	som_rebate.stream = preload("res://itens/pedra/SomRebate.mp3")
	som_rolando.stream = preload("res://itens/pedra/SomRolando.wav")
	body_entered.connect(_on_body_entered)
func _physics_process(_delta: float) -> void:
	if _ativa or _animando or not is_instance_valid(corpo):
		return
	var direcao_frente = corpo.global_transform.basis.z
	global_position = corpo.global_position + direcao_frente * 2.0
	global_position.y = corpo.global_position.y
func usar() -> void:
	if _ativa:
		return
	_ativa = true
	_animando = true
	usos -= 1
	reparent(pai)
	var lado = corpo.global_transform.basis.x * 2.0
	var direcao_frente = -corpo.global_transform.basis.z
	var pos_meio = corpo.global_position + lado + Vector3(0, 1.5, 0)
	var pos_fim = corpo.global_position + direcao_frente * 2.0 + Vector3(0, 1.2, 0)
	modelo.scale = Vector3.ONE * 0.3
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos_meio, 0.00)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", pos_fim, 0.00)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(modelo, "scale", Vector3.ONE * 3.5, 0.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished
	_animando = false
	_direcao = -corpo.global_transform.basis.z
	freeze = false
	gravity_scale = 30.0
	lock_rotation = true
	linear_velocity = _direcao * VELOCIDADE
	anim.play("pedra")
	som_rolando.play()
	# aguarda 0.5s e habilita colisão com tudo
	await get_tree().create_timer(0.5).timeout
	remove_collision_exception_with(corpo)
	collision_mask = 0xFFFFFFFF  # detecta todas as layers
	await get_tree().create_timer(8.5).timeout
	if is_instance_valid(self):
		queue_free()
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _ativa or _animando or _direcao == Vector3.ZERO:
		return
	if state.linear_velocity.length() < VELOCIDADE * 0.5:
		for i in state.get_contact_count():
			var normal = state.get_contact_local_normal(i)
			if abs(normal.y) < 0.3:
				_direcao = _direcao.bounce(normal).normalized()
				som_rebate.play()
				break
	var dir_horizontal = Vector3(_direcao.x, 0, _direcao.z).normalized()
	if dir_horizontal.length() > 0.1:
		state.linear_velocity = dir_horizontal * VELOCIDADE + Vector3(0, state.linear_velocity.y, 0)
func _on_body_entered(body: Node) -> void:
	if not _ativa:
		return
	if body is CharacterBody3D:
		if body.has_method("levar_dano"):
			body.levar_dano(_direcao)  # passa a direção da pedra
		queue_free()
