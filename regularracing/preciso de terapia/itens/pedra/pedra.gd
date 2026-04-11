extends RigidBody3D
var pai: Node3D
var corpo: CharacterBody3D
var usos := 1
@onready var modelo: Node3D = $preda
@onready var anim: AnimationPlayer = $AnimationPlayer
var _ativa := false
const VELOCIDADE := 100.0

func configurar(player: CharacterBody3D) -> void:
	corpo = player
	pai = player.get_parent()
	freeze = true
	contact_monitor = true
	max_contacts_reported = 4

func _physics_process(_delta: float) -> void:
	if _ativa or not is_instance_valid(corpo):
		return
	var direcao_frente = corpo.global_transform.basis.z
	global_position = corpo.global_position + direcao_frente * 2.0
	global_position.y = corpo.global_position.y

func usar() -> void:
	if _ativa:
		return
	_ativa = true
	usos -= 1
	reparent(pai)

	var direcao_frente = -corpo.global_transform.basis.z

	# sobe rápido
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector3(0, 1.5, 0), 0.1)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	await tween.finished

	# ativa gravidade normal para descer e acompanhar o chão
	freeze = false
	gravity_scale = 1.0
	lock_rotation = true
	linear_velocity = direcao_frente * VELOCIDADE
	anim.play("pedra")

	await get_tree().create_timer(0.5).timeout
	body_entered.connect(_on_body_entered)

var _rebater := false

func _on_body_entered(body: Node) -> void:
	if body == corpo:
		return
	if body is CharacterBody3D:
		if body.has_method("receber_dano"):
			body.receber_dano()
		queue_free()
		return
	_rebater = true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _rebater:
		return
	_rebater = false
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		if normal.y > 0.5:
			return  # é chão, ignora
	linear_velocity.x = -linear_velocity.x
	linear_velocity.z = -linear_velocity.z
