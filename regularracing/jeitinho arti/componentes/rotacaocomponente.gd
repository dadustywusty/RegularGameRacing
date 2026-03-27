extends RayCast3D
class_name RotacaoComponente

@export var corpo : CharacterBody3D

func tick(delta) -> void:
	if not is_colliding():
		return
	
	var n = get_collision_normal()
	var xform = alinhar(corpo.global_transform, n.normalized())
	corpo.global_transform = corpo.global_transform.interpolate_with(xform, 10 * delta)
	

func alinhar(xform, novo_y):
	xform.basis.y = novo_y
	xform.basis.x = -xform.basis.z.cross(novo_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
