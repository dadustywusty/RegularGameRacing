extends Node3D

var modulos := [
	preload("uid://b5ju7omacmpt4"), # regular 1
	preload("uid://t82f1ai8ssgo"), # regular 2
	preload("uid://pdhjccy3hcpe") # regular 3
]
var icones := {
	preload("uid://b5ju7omacmpt4"):  preload("res://pistas/regular circuit/regular1.png"),
	preload("uid://t82f1ai8ssgo"): preload("res://pistas/regular circuit/regular2.png"),
	preload("uid://pdhjccy3hcpe"): preload("res://pistas/regular circuit/regular3.png"),
}

@onready var grupo_1_cp := [
	$"checkpoints/checkpoint 3",
	$"checkpoints/checkpoint 4",
	$"checkpoints/checkpoint 5",
	$"checkpoints/checkpoint 6",
	$"checkpoints/checkpoint 7"
]
@onready var grupo_2_cp := [
	$"checkpoints/checkpoint 10",
	$"checkpoints/checkpoint 11",
	$"checkpoints/checkpoint 12",
	$"checkpoints/checkpoint 13",
	$"checkpoints/checkpoint 14"
]

@onready var cp_modular := [grupo_1_cp, grupo_2_cp]
