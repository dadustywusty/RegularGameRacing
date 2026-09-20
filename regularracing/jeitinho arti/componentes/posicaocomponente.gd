extends Node
class_name PosiçaoComponente

signal termino
signal corrida_finalizada(tempo_total: float)

var posicao : int
var volta := 1
var ultimo_cp_idx := -1
var progresso := 0.0
var cp_passados := 0
var tempo_atual : float
var acabou := false

@onready var checkpoints = get_tree().get_first_node_in_group("container checkpoints").get_children()
@onready var total_checkpoints = checkpoints.size()

# Configurações de término
@export var volta_final := 4  # Muda aqui se quiser mais/menos voltas
@export var tempo_espera_mudanca_cena := 2.0  # Tempo antes de mudar de cena
@export var cena_resultado := "res://cenas/resultado_corrida.tscn"  # Cena para ir após terminar

var ja_terminou := false
var tempo_termino := 0.0

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
	
	# Verifica se terminou a corrida
	if volta >= volta_final and not ja_terminou:
		_finalizar_corrida()
	
	# Se terminou, conta o tempo para mudar de cena
	if ja_terminou:
		tempo_termino += delta
		if tempo_termino >= tempo_espera_mudanca_cena:
			_mudar_para_cena_resultado()

func passou_checkpoint(checkpoint_id: int) -> void:
	if checkpoint_id > ultimo_cp_idx or (ultimo_cp_idx == total_checkpoints - 1 and checkpoint_id == 0):
		if checkpoint_id == 0 and ultimo_cp_idx != -1:
			if cp_passados >= total_checkpoints * 0.8:
				volta += 1
				cp_passados = 0
				print("Completou volta %d/%d" % [volta, volta_final])
		if checkpoint_id != ultimo_cp_idx:
			ultimo_cp_idx = checkpoint_id
			cp_passados += 1

func _finalizar_corrida() -> void:
	"""Para o movimento e emite sinal de término"""
	ja_terminou = true
	acabou = true
	
	# Para o movimento do carro
	var carro = get_parent()
	if carro and carro.has_method("parar"):
		carro.parar()
	else:
		# Se não tem método parar, zera a velocidade
		if carro and carro.has_property("velocity"):
			carro.velocity = Vector3.ZERO
	
	print("✓ Corrida finalizada! Tempo total: %s" % converter_tempo_pra_string(tempo_atual))
	
	# Emite os sinais
	termino.emit()
	corrida_finalizada.emit(tempo_atual)

func _mudar_para_cena_resultado() -> void:
	"""Muda para a cena de resultado"""
	print("🎬 Mudando para cena de resultado...")
	
	# Se tiver transição, usar
	if Transicao:
		Transicao.transicionar("res://acabou.tscn")
	else:
		# Senão, muda direto
		get_tree().change_scene_to_file(cena_resultado)

func _on_respawn_componente_checkpoint_passado(id: int) -> void:
	passou_checkpoint(id)

func converter_tempo_pra_string(tempo: float) -> String:
	var minutos: int = int(tempo / 60.0) % 60
	var segundos: int = int(tempo) % 60
	var milisegundos: int = int(tempo * 1000.0) % 1000
	var string: String = "%02d.%03d, Lap %d/%d" % [segundos, milisegundos, volta, volta_final]
	if minutos > 0:
		string = string.insert(0, ("%d:") % minutos)
	return string

func get_tempo_final() -> float:
	"""Retorna o tempo total da corrida"""
	return tempo_atual

func get_volta_atual() -> int:
	"""Retorna a volta atual"""
	return volta

func get_volta_final() -> int:
	"""Retorna o número de voltas total"""
	return volta_final
