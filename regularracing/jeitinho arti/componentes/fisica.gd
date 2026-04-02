extends RayCast3D
class_name FisicaComponente

@export var corpo: RigidBody3D

@export var forca_pulo: float = 11.0

var velocidade_vertical: float = 0.0
var no_chao : bool

func tick() -> void:
	no_chao = is_colliding()
	print(no_chao)
	if no_chao:
		velocidade_vertical = 0.0
		if _input_pulo():
			velocidade_vertical = forca_pulo

func _input_pulo() -> bool:
	return Input.is_action_just_pressed("drift")

func _on_trick_componente_trick_pulo() -> void:
	velocidade_vertical = 25.0
