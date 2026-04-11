extends RigidBody3D
var pai: Node3D
var corpo: CharacterBody3D
var usos := 1
@onready var modelo: Node3D = $preda
@onready var anim: AnimationPlayer = $AnimationPlayer
var _ativa := false
var _animando := false
var _direcao := Vector3.ZERO
const VELOCIDADE := 150.0

func configurar(player: CharacterBody3D) -> void:
	corpo = player
	pai = player.get_parent()
	freeze = true
	contact_monitor = true
	max_contacts_reported = 4
	anim.stop()
	add_collision_exception_with(player)

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
	var pos_meio = corpo.global_position + lado + Vector3(0, 2.0, 0)
	var direcao_frente = -corpo.global_transform.basis.z
	var pos_fim = corpo.global_position + direcao_frente * 2.0 + Vector3(0, 1.5, 0)

	var tween = create_tween()
	tween.tween_property(self, "global_position", pos_meio, 0.0000001)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", pos_fim, 0.00000001)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	modelo.scale = Vector3.ONE * 0.3
	tween.parallel().tween_property(modelo, "scale", Vector3.ONE * 2.5, 0.01)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished
	_animando = false

	_direcao = -corpo.global_transform.basis.z
	freeze = false
	gravity_scale = 50.0
	lock_rotation = true
	linear_velocity = _direcao * VELOCIDADE
	anim.play("pedra")

	await get_tree().create_timer(9.0).timeout
	if is_instance_valid(self):
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _ativa or _animando or _direcao == Vector3.ZERO:
		return
	var vel_atual = state.linear_velocity
	if vel_atual.length() < VELOCIDADE * 0.5:
		for i in state.get_contact_count():
			var normal = state.get_contact_local_normal(i)
			if abs(normal.y) < 0.3:
				_direcao = _direcao.bounce(normal).normalized()
				break
	state.linear_velocity = _direcao * VELOCIDADE

func _on_body_entered(body: Node) -> void:
	if body == corpo:
		return
	if body is CharacterBody3D:
		if body.has_method("receber_dano"):
			body.receber_dano()
		queue_free()
