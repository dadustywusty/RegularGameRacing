extends Node
class_name PosiçaoComponente

var posicao : int
var volta := 1
var ultimo_cp_idx := -1
var progresso := 0.0

func tick() -> void:
	var checkpoints = get_parent().get_parent().get_node("checkpoints").get_children()
	var base = (volta * 1000) + (ultimo_cp_idx * 10)
	var prox_idx = (ultimo_cp_idx + 1) % checkpoints.size()
	var prox_cp = checkpoints[prox_idx]
	var distancia = get_parent().global_position.distance_to(prox_cp.global_position)
	
	progresso = base - distancia
