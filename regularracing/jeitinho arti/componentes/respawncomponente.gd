extends Area3D
class_name RespawnComponente

@export var corpo : CharacterBody3D
var checkpoint_atual : Area3D
var respawn : Node3D

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("checkpoint"):
		checkpoint_atual = area
		for node in checkpoint_atual.get_children():
			if node.is_in_group("ponto respawn"):
				respawn = node
	
	if area.is_in_group("plano morte"):
		corpo.global_transform = respawn.global_transform
		corpo.velocity = Vector3.ZERO
