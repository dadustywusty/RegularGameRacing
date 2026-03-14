extends RayCast3D
class_name RotacaoComponente

@export var corpo : CharacterBody3D

func tick() -> void:
	if not is_colliding():
		return
	
	# pega o cima do chao atual
	var n = get_collision_normal()
	# mantem a direçao lateral
	var x_axis = corpo.global_transform.basis.x
	# calcula a frente nova cruzando o lado e o "cima" novo
	var z_axis = x_axis.cross(n).normalized()
	# calcula o x dnv pra deixar tudo perpendicular perfeitamente
	x_axis = n.cross(z_axis).normalized()
	# aplica a rotaçao
	var base = Basis(x_axis, n, z_axis)
	corpo.global_transform.basis = corpo.global_transform.basis.slerp(base, 0.2)
	
