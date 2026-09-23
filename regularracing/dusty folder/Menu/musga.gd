extends Node

@onready var loop: AudioStreamPlayer = $Loop
@onready var intro: AudioStreamPlayer = $Intro

const MUSICA_MENU := preload("res://dusty folder/MUSGA/corrida menu.ogg")
const DELAY_ANTES_INTRO := 1.0

var _musica_atual: String = ""

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
	_musica_atual = "menu"
	loop.stream = MUSICA_MENU
	loop.stream.loop = true
	loop.play()

func tocar_musica(stream: AudioStream, nome: String) -> void:
	if _musica_atual == nome:
		return
	loop.stop()
	intro.stop()
	_musica_atual = nome
	loop.stream = stream
	loop.stream.loop = true
	loop.play()

func tocar_musica_com_intro(intro_stream: AudioStream, loop_stream: AudioStream, nome: String) -> void:
	if _musica_atual == nome:
		return
	loop.stop()
	intro.stop()
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
		loop.play()

func parar() -> void:
	loop.stop()
	intro.stop()
	_musica_atual = ""

func tocar_hover() -> void:
	pass

func tocar_click(acao: Callable) -> void:
	acao.call()
