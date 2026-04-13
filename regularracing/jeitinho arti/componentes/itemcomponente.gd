extends Node3D
class_name ItemComponente

var item_atual
var tem_item := false
var item_input : bool

var itens: Dictionary = {
	#"latinha": preload("uid://buu6imckneitw"),
	#"latinhas triplas": preload("uid://jhdftpvqvih3"),
	#"molinha": preload("uid://bpspel1hunwcc"),
	"pedra": preload("res://itens/pedra/pedra.tscn")
}

func tick() -> void:
	if item_atual:
		# Só controla posição se ainda NÃO foi usado
		if not item_atual.has_method("_ativa") or not item_atual._ativa:
			item_atual.global_transform = global_transform
		
		# remove da HUD quando acabar
		if "usos" in item_atual and item_atual.usos <= 0:
			item_atual = null
			tem_item = false

	# usar item
	if tem_item and item_input and item_atual:
		if item_atual.has_method("usar"):
			item_atual.usar()
