extends Node
class_name FumacaComponente

# arrasta os dois GPUParticles3D aqui no Inspector
@export var fumaca_esquerda: GPUParticles3D
@export var fumaca_direita: GPUParticles3D

var drift: bool = false

func tick() -> void:
	fumaca_esquerda.emitting = drift
	fumaca_direita.emitting = drift
