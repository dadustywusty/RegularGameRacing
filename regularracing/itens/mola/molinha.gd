extends Node3D

var _trick: TrickComponente
var turbo: TurboComponente
var fisica
var usos := 1

@onready var som: AudioStreamPlayer3D = $GravityCoil/som

@onready var modelo: Node3D = $GravityCoil
var _escala_original: Vector3
var _usando: bool = false

func _ready() -> void:
	_escala_original = modelo.scale
	modelo.scale = Vector3.ZERO
	var tween = create_tween()
	tween.tween_property(modelo, "scale", _escala_original, 0.4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

func configurar(player: CharacterBody3D) -> void:
	fisica = player.fisica
	_trick = player.trick_componente
	
func usar() -> void:
	som.play()
	if _usando:
		return
	_usando = true
	usos -= 1
	
	fisica.velocidade_vertical = 34.5
	
	# força o trick independente do chão
	if _trick:
		_trick.pode_trick = true
		await get_tree().create_timer(0.8).timeout
		_trick.pode_trick = false
	
	var tween = modelo.create_tween()
	tween.tween_property(modelo, "scale", Vector3.ZERO, 0.15)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC) #transparente seus bobocas, não confudam
	tween.tween_callback(queue_free)
