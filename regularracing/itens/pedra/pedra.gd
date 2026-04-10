extends RigidBody3D

@onready var modelo: Node3D = $preda
var pai : Node3D
var corpo : CharacterBody3D

var usos := 1

func configurar(player: CharacterBody3D) -> void:
	corpo = player
	pai = player.get_parent()

func usar() -> void:
	usos -= 1
	reparent(pai)
	global_position.z = corpo.global_position.z - 2.0
