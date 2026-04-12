extends Node3D
class_name ItemComponente

var item_atual
var tem_item := false
var item_input : bool

var itens: Dictionary = {
	"latinha": preload("uid://buu6imckneitw"),
	"latinhas triplas": preload("uid://jhdftpvqvih3"),
	"molinha": preload("uid://bpspel1hunwcc"),
	"pedra": preload("uid://7uk04ilajpgx")
}

func tick() -> void:
	if item_atual:
		item_atual.global_transform = global_transform
		if item_atual.usos == 0:
			tem_item = false
			item_atual = null
	if tem_item and item_input:
		item_atual.usar()
