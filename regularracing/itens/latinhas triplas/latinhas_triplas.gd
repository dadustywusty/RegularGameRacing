extends Node3D

var turbo: TurboComponente
var usos := 3

@onready var latinhas: Array[Node3D] = [
	$pivot/latinha,
	$pivot/latinha2,
	$pivot/latinha3
]

var _usando: bool = false
var _escala_original: Vector3

func _ready() -> void:
	_escala_original = latinhas[0].scale
	# cada latinha cresce ao aparecer com delay
	for i in latinhas.size():
		latinhas[i].scale = Vector3.ZERO
		var tween = create_tween()
		tween.tween_interval(i * 0.1)  # delay entre cada uma
		tween.tween_property(latinhas[i], "scale", _escala_original, 0.4)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BACK)

func configurar(player: CharacterBody3D) -> void:
	turbo = player.turbo

func usar() -> void:
	if _usando:
		return
	_usando = true
	
	turbo.forca_turbo = 100
	turbo.duracao_turbo = 1.0
	turbo.ativar()
	
	# pega a latinha atual (última da lista)
	var index = usos - 1
	var latinha_atual = latinhas[index]
	usos -= 1
	
	# encolhe e some
	var tween = latinha_atual.create_tween()
	tween.tween_property(latinha_atual, "scale", Vector3.ZERO, 0.15)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		var som = latinha_atual.get_node_or_null("som")
		if som:
			som.pitch_scale = randf_range(0.8, 1.2)
			som.play()
			som.finished.connect(func():
				latinha_atual.queue_free()
			)
		else:
			latinha_atual.queue_free()
	)

	_usando = false
