extends Node
class_name PosiçaoComponente

signal termino

var posicao : int
var volta := 1
var ultimo_cp_idx := -1
var progresso := 0.0
var cp_passados := 0

var tempo_atual : float
var acabou := false

@onready var checkpoints = get_tree().get_first_node_in_group("container checkpoints").get_children()
@onready var total_checkpoints = checkpoints.size()

func tick(delta: float) -> void:
	if checkpoints.is_empty():
		return
	
	var base = (volta * 1000) + (ultimo_cp_idx * 10)
	var prox_idx = (ultimo_cp_idx + 1) % checkpoints.size()
	var prox_cp = checkpoints[prox_idx]
	var distancia = get_parent().global_position.distance_to(prox_cp.global_position)
	
	progresso = base - distancia
	
	if not acabou:
		tempo_atual += delta
	
	if volta > 3:
		acabou = true
		termino.emit()

func passou_checkpoint(checkpoint_id: int) -> void:
	if checkpoint_id > ultimo_cp_idx or (ultimo_cp_idx == total_checkpoints - 1 and checkpoint_id == 0):
		if checkpoint_id == 0 and ultimo_cp_idx != -1:
			if cp_passados  >= total_checkpoints * 0.8:
				volta += 1
				cp_passados = 0
		if checkpoint_id != ultimo_cp_idx:
			ultimo_cp_idx = checkpoint_id
			cp_passados += 1

func _on_respawn_componente_checkpoint_passado(id: int) -> void:
	passou_checkpoint(id)

func converter_tempo_pra_string(tempo: float) -> String:
	var minutos: int = int(tempo / 60.0) % 60
	var segundos: int = int(tempo) % 60
	var milisegundos: int = int(tempo * 1000.0) % 1000
	var string: String = "%02d.%03d, Lap %d/3" % [segundos, milisegundos, volta]
	if minutos > 0:
		string = string.insert(0, ("%d:") % minutos)
	return string
