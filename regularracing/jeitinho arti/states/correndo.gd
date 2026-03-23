extends State
class_name Correndo

@export var corpo: CharacterBody3D

func update(_delta: float):
	if corpo.linear_velocity < 0:
		transicionou.emit(self, "parado")
