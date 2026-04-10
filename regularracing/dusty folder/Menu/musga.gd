extends Node

@onready var loop: AudioStreamPlayer  = $Loop

func _ready() -> void:
	
	loop.stream  = preload("res://dusty folder/MUSGA/corrida menu.ogg")
	loop.stream.loop = true  # marca o loop
	
	
	loop.play()

func tocar_hover() -> void:
	pass  # adiciona seu som de hover aqui

func tocar_click(acao: Callable) -> void:
	pass  # adiciona seu som de click aqui
	acao.call()
