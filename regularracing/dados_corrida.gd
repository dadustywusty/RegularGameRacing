extends Node

var tempo_final: float = 0.0
var voltas: int = 0
var total_voltas: int = 0

func salvar(tempo: float, v: int, tv: int) -> void:
	tempo_final = tempo
	voltas = v
	total_voltas = tv

func limpar() -> void:
	tempo_final = 0.0
	voltas = 0
	total_voltas = 0
