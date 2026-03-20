extends Node
class_name FisicaComponente

@export var corpo: CharacterBody3D

@export var gravidade: float = 70
@export var forca_pulo: float = 9.0

var velocidade_vertical: float = 0.0
var no_chao: bool = false

func tick(delta: float) -> void:
	if no_chao:
		velocidade_vertical = 0.0
		if _input_pulo():
			velocidade_vertical = forca_pulo
	else:
		velocidade_vertical -= gravidade * delta

func _input_pulo() -> bool:
	return Input.is_action_just_pressed("drift")
