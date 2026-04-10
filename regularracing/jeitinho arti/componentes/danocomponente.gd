extends Area3D
class_name DanoComponente

@export var corpo : CharacterBody3D

var pode_dano := true

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("dano"):
		if pode_dano:
			pode_dano = false
			corpo.levar_dano()
			await get_tree().create_timer(1.0).timeout
			pode_dano = true
