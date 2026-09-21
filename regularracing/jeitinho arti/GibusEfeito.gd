extends Sprite3D

@export var trick_componente: TrickComponente

@export_group("Texturas de Trick")
@export var texturas: Array[Texture2D] = []   # ← arrasta as imagens aqui no Inspector

const ESCALA_PEQUENA := Vector3(0.3, 0.3, 0.3)
const ESCALA_GRANDE  := Vector3(6.7, 6.7, 6.7)
const DURACAO_CRESCE := 0.15
const DURACAO_SOME   := 0.4
const TEMPO_VISIVEL  := 0.3
const ALPHA_MAX      := 0.75

var _tween: Tween
var _ultimo_indice := -1   # evita repetir a mesma imagem duas vezes seguidas

func _ready() -> void:
	visible = false
	scale = ESCALA_PEQUENA
	modulate.a = 0.0

	if trick_componente == null:
		trick_componente = get_parent().find_child("TrickComponente", true, false)

	if trick_componente == null:
		print(">>> ERRO: TrickComponente não encontrado")
		return

	if texturas.is_empty():
		print(">>> AVISO: nenhuma textura configurada no GibusEfeito")
		return

	trick_componente.trick_pulo.connect(_on_trick)

func _on_trick() -> void:
	_sortear_textura()
	_animar()

func _sortear_textura() -> void:
	if texturas.is_empty():
		return

	# Sorteia um índice diferente do último (se tiver mais de 1 textura)
	var novo_indice: int
	if texturas.size() == 1:
		novo_indice = 0
	else:
		var tentativas := 0
		while tentativas < 10:
			novo_indice = randi() % texturas.size()
			if novo_indice != _ultimo_indice:
				break
			tentativas += 1

	_ultimo_indice = novo_indice
	texture = texturas[novo_indice]

func _animar() -> void:
	if _tween:
		_tween.kill()

	visible = true
	scale = ESCALA_PEQUENA
	modulate.a = 0.0

	_tween = create_tween().set_parallel(false)

	# 1. Cresce + aparece
	_tween.set_parallel(true)
	_tween.tween_property(self, "scale", ESCALA_GRANDE, DURACAO_CRESCE).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", ALPHA_MAX, DURACAO_CRESCE)
	_tween.set_parallel(false)

	# 2. Espera
	_tween.tween_interval(TEMPO_VISIVEL)

	# 3. Encolhe + some
	_tween.set_parallel(true)
	_tween.tween_property(self, "scale", ESCALA_PEQUENA, DURACAO_SOME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate:a", 0.0, DURACAO_SOME)
	_tween.chain().tween_callback(func(): visible = false)
