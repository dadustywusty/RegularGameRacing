extends Node3D

var modulos := [
	preload("uid://74v6laavjv6a"),
	preload("uid://b2grv3605w2cx"),
	preload("uid://eakm2yw4j6pe")
]
var icones := {
	preload("uid://74v6laavjv6a"):  preload("res://pistas/regular circuit/regular1.png"),
	preload("uid://b2grv3605w2cx"): preload("res://pistas/regular circuit/regular3.png"),
	preload("uid://eakm2yw4j6pe"):  preload("res://pistas/regular circuit/regular2.png"),
}

var grupo_1_cp := [
	$"checkpoints/checkpoint 3",
	$"checkpoints/checkpoint 4",
	$"checkpoints/checkpoint 5",
	$"checkpoints/checkpoint 6",
	$"checkpoints/checkpoint 7"
]
var grupo_2_cp := [
	$"checkpoints/checkpoint 10",
	$"checkpoints/checkpoint 11",
	$"checkpoints/checkpoint 12",
	$"checkpoints/checkpoint 13",
	$"checkpoints/checkpoint 14"
]

var cp_modular := [grupo_1_cp, grupo_2_cp]
