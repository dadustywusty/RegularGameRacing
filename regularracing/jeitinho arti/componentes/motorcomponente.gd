extends Node
class_name MotorComponente

@export var som_motor: AudioStreamPlayer3D
@export var velocidade_max: float = 40.0
@export var pitch_min: float = 0.6  # motor em idle
@export var pitch_max: float = 2.0  # motor a fundo

func _ready() -> void:
	if som_motor:
		som_motor.play()

func tick(velocidade: float) -> void:
	if som_motor == null:
		return
	var t = clamp(abs(velocidade) / velocidade_max, 0.0, 1.0)
	som_motor.pitch_scale = lerp(pitch_min, pitch_max, t)
