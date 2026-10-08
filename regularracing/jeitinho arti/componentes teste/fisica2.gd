extends Node
class_name FisicaComponente2

@export var corpo : CharacterBody3D

@onready var resistencia_do_ar = get_parent().get_parent().resistencia_do_ar
@onready var gravidade = get_parent().get_parent().gravidade
@onready var peso : float = corpo.stats.peso

var forcas := Vector3.ZERO
var impulsos := Vector3.ZERO

func tick(delta: float) -> void:
	var friccao : float = corpo.friccao
	var momentum := corpo.get_real_velocity()
	
	if not corpo.is_on_floor():
		var cima := corpo.global_basis.y
		var vel_cima := corpo.velocity.dot(cima) * cima
		
		aplicar_forca(Vector3.DOWN * gravidade * peso)
		aplicar_forca((momentum + vel_cima) * 4)
	
	else:
		var frente := -corpo.global_basis.z
		var vel_frente := corpo.velocity.dot(frente)
		var lado := -corpo.global_basis.x
		var vel_lado := corpo.velocity.dot(lado)
		
		vel_frente = lerpf(vel_frente, 0.0, resistencia_do_ar * delta)
		vel_lado = lerpf(vel_lado, 0.0, friccao * delta)
		aplicar_forca((vel_frente * frente) + (vel_lado * lado))
	
	
	corpo.velocity += forcas * delta
	corpo.velocity += impulsos
	
	corpo.velocity = corpo.velocity.lerp(Vector3.ZERO, resistencia_do_ar * delta)

func aplicar_forca(forca_nova: Vector3) -> void:
	forcas += forca_nova

func aplicar_impulso(impulso_novo) -> void:
	impulsos += impulso_novo

func limpar() -> void:
	forcas = Vector3.ZERO
	impulsos = Vector3.ZERO
