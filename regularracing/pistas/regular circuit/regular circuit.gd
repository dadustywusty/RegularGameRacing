extends Node3D

var modulos := [
	preload("uid://b5ju7omacmpt4"),
	preload("uid://t82f1ai8ssgo"),
	preload("uid://pdhjccy3hcpe")
]
var icones := {
	preload("uid://b5ju7omacmpt4"): preload("res://pistas/regular circuit/regular1.png"),
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

const MUSICA_INTRO := preload("res://dusty folder/MUSGA/Project_54.ogg")
const MUSICA_LOOP  := preload("res://dusty folder/MUSGA/Project_54 intro.ogg")
const MUSICA_ACABOU := preload("res://preciso de terapia/dusty folder/MUSGA/Project_54 gracinha edition.ogg")

func _ready() -> void:
	Musga.tocar_musica_com_intro(MUSICA_INTRO, MUSICA_LOOP, "regular_circuit")
	
	# Espera a intro tocar pra sincronizar a versão alternativa
	await get_tree().create_timer(2.0).timeout   # ajusta pro tempo da intro
	Musga.sincronizar_versao_alternativa(MUSICA_ACABOU)
