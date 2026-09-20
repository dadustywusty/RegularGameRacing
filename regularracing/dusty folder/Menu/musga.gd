extends Node

@onready var loop: AudioStreamPlayer = $Loop

func _ready() -> void:
	loop.stream = preload("res://dusty folder/MUSGA/corrida menu.ogg")
	loop.stream.loop = true
	if not loop.playing:
		loop.play()

func tocar_hover() -> void:
	pass

func tocar_click(acao: Callable) -> void:
	acao.call()
