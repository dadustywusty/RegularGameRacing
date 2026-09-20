extends Sprite3D

@export var trick_componente: TrickComponente

const ESCALA_PEQUENA := Vector3(0.3, 0.3, 0.3)
const ESCALA_GRANDE  := Vector3(6.7, 6.7, 6.7)
const DURACAO_CRESCE := 0.15
const DURACAO_SOME   := 0.4
const TEMPO_VISIVEL  := 0.3

var _tween: Tween

func _ready() -> void:
	visible = false
	scale = ESCALA_PEQUENA
	modulate.a = 0.7

	if trick_componente == null:
			trick_componente = get_parent().find_child("TrickComponente", true, false)

	if trick_componente == null:
		print(">>> ERRO: TrickComponente não encontrado para o GibusEfeito")
		return

	trick_componente.trick_pulo.connect(_on_trick)

func _on_trick() -> void:
	_animar()

func _animar() -> void:
	if _tween:
		_tween.kill()

	visible = true
	scale = ESCALA_PEQUENA
	modulate.a = 1.0

	_tween = create_tween().set_parallel(false)

	_tween.tween_property(self, "scale", ESCALA_GRANDE, DURACAO_CRESCE).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	
	_tween.tween_interval(TEMPO_VISIVEL)

	_tween.set_parallel(true)
	_tween.tween_property(self, "scale", ESCALA_PEQUENA, DURACAO_SOME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate:a", 0.0, DURACAO_SOME)

	_tween.chain().tween_callback(func(): visible = false)
