extends Node3D
class_name ItemComponente

var item_atual
var tem_item := false

func tick() -> void:
	if item_atual:
		print(item_atual.usos)
		item_atual.global_transform = global_transform
		if item_atual.usos == 0:
			tem_item = false
			item_atual.queue_free()
	if tem_item and Input.is_action_just_pressed("item"):
		item_atual.usar()
		item_atual.usos -= 1
