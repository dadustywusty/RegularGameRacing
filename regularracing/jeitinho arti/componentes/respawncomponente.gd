extends Area3D
class_name RespawnComponente

@export var corpo : CharacterBody3D

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("plano morte"):
		var respawn = get_tree().get_first_node_in_group("ponto respawn")
		corpo.transform = respawn.transform
