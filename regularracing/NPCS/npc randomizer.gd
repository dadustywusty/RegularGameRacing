extends Node

@onready var tex1 = preload("uid://cs3ahpejcl2b7") #artemi
@onready var tex2 = preload("uid://21wy0pf05887") #bandido
@onready var tex3 = preload("uid://yq3aey1j5oxd") #ferreira
@onready var tex4 = preload("uid://ctyojenwwdr3u") #cacto
@onready var tex5 = preload("uid://cifjonyix4s1y") #noon, REMOVIDO
@onready var tex6 = preload("uid://o0c1neh74qhl") #detetive, REMOVIDO
@onready var tex7 = preload("uid://ckp8fmgd5nyvu") #dusty
@onready var tex8 = preload("uid://b6tptneiu3vtn") #gangster
@onready var tex9 = preload("uid://d2ar0wwats1o0") #artemi pyro, REMOVIDO
@onready var tex10 = preload("uid://byn8hlrpw70hf") #dusty engi, REMOVIDO
@onready var tex11 = preload("uid://csljej8fgfjo7") #ryan npc, REMOVIDO
@onready var tex12 = preload("uid://gd6nono2art2") #xerife
@onready var tex13 = preload("uid://0wwkd5i4hl5x") #sniper

func _ready() -> void:
	var texturas := [tex1, tex2, tex3, tex4, tex7, tex8, tex12, tex13]
	var npcs := get_children()
	for i in npcs:
		var textura_escolhida = texturas.pick_random()
		i.texture = textura_escolhida
