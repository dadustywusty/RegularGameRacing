extends Node

@onready var loop: AudioStreamPlayer = $Loop
@onready var intro: AudioStreamPlayer = $Intro
@onready var loop_b: AudioStreamPlayer = $LoopB

const MUSICA_MENU := preload("res://dusty folder/MUSGA/corrida menu.ogg")
const DELAY_ANTES_INTRO := 1.0
const TEMPO_CROSSFADE := 0.8

var _musica_atual: String = ""
var _stream_sincronizado: AudioStream = null

func _ready() -> void:
	loop.stream = MUSICA_MENU
	loop.stream.loop = true
	loop.play()
	_musica_atual = "menu"

func tocar_menu() -> void:
	if _musica_atual == "menu":
		return
	loop.stop()
	intro.stop()
	loop_b.stop()
	_musica_atual = "menu"
	loop.stream = MUSICA_MENU
	loop.stream.loop = true
	loop.volume_db = 0.0
	loop.play()

func tocar_musica(stream: AudioStream, nome: String) -> void:
	if _musica_atual == nome:
		return
	loop.stop()
	intro.stop()
	loop_b.stop()
	_musica_atual = nome
	loop.stream = stream
	loop.stream.loop = true
	loop.volume_db = 0.0
	loop.play()

func tocar_musica_com_intro(intro_stream: AudioStream, loop_stream: AudioStream, nome: String) -> void:
	if _musica_atual == nome:
		return
	loop.stop()
	intro.stop()
	loop_b.stop()
	_musica_atual = nome
	await get_tree().create_timer(DELAY_ANTES_INTRO).timeout
	if _musica_atual != nome:
		return
	intro.stream = intro_stream
	intro.play()
	await intro.finished
	if _musica_atual == nome:
		loop.stream = loop_stream
		loop.stream.loop = true
		loop.volume_db = 0.0
		loop.play()

func sincronizar_versao_alternativa(stream: AudioStream) -> void:
	_stream_sincronizado = stream
	loop_b.stream = stream
	loop_b.stream.loop = true
	loop_b.volume_db = -80.0
	loop_b.play()
	loop_b.seek(loop.get_playback_position())

func crossfade_para_alternativa() -> void:
	if loop_b.stream == null:
		return
	loop_b.seek(loop.get_playback_position())
	var tween = create_tween().set_parallel(true)
	tween.tween_property(loop, "volume_db", -80.0, TEMPO_CROSSFADE)
	tween.tween_property(loop_b, "volume_db", 0.0, TEMPO_CROSSFADE)
	await tween.finished
	loop.stop()
	loop_b.volume_db = 0.0
	_musica_atual = "alternativa"

func parar() -> void:
	loop.stop()
	intro.stop()
	loop_b.stop()
	_musica_atual = ""

func tocar_hover() -> void:
	pass

func tocar_click(acao: Callable) -> void:
	acao.call()
