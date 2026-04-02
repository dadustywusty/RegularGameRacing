extends Node3D

var turbo: TurboComponente
var usos := 1

@onready var modelo: Node3D = $AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZ
@onready var som: AudioStreamPlayer3D = $som

var _escala_original: Vector3
var _usando: bool = false

func _ready() -> void:
	_escala_original = modelo.scale
	# começa pequeno e cresce
	modelo.scale = Vector3.ZERO
	var tween = create_tween()
	tween.tween_property(modelo, "scale", _escala_original, 0.4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

func configurar(player: CharacterBody3D) -> void:
	turbo = player.turbo

func usar() -> void:
	if _usando:
		return
	_usando = true
	usos -= 1

	# ativa o turbo
	turbo.forca_turbo = 100
	turbo.duracao_turbo = 1.0
	turbo.ativar()

	# encolhe rapidinho
	var tween = create_tween()
	tween.tween_property(modelo, "scale", Vector3.ZERO, 0.15)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		som.play()
	)
	# some quando o som acabar
	som.finished.connect(func():
		queue_free()
	)
