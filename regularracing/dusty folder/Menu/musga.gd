extends Node

@onready var intro: AudioStreamPlayer = $Intro
@onready var loop: AudioStreamPlayer  = $Loop

func _ready() -> void:
	intro.stream = preload("res://dusty folder/MUSGA/Project_54 intro.ogg")
	loop.stream  = preload("res://dusty folder/MUSGA/Project_54.ogg")
	loop.stream.loop = true  # marca o loop
	
	intro.play()
	await intro.finished
	loop.play()

func tocar_hover() -> void:
	pass  # adiciona seu som de hover aqui

func tocar_click(acao: Callable) -> void:
	pass  # adiciona seu som de click aqui
	acao.call()
