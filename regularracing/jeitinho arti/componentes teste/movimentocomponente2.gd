extends Node
class_name MovimentoComponente2

# esse script lida APENAS com movimento, ele não lê input

@export var corpo : CharacterBody3D

@onready var fisica_componente: FisicaComponente2 = %FisicaComponente2

# esse parametro é o mesmo da aceleração do inputcomponente
var impulso := 0.0
# mesma coisa do de cima
var rotacao := 0.0
var velocidade_turbo: float = 0.0

# modificadores, aplicados pelo tipo de terreno
var mod_vel := 1.0
var mod_acc := 1.0
var mod_fri := 1.0

var volante := 0.0
var pedal := 0.0

func tick(delta: float) -> void:
	var velocidade : float = corpo.stats.velocidade
	var angulo : float = corpo.angulo_virada
	var aceleracao : float = corpo.stats.aceleracao if impulso != 1.0 else 7.0
	var friccao : float = corpo.friccao
	
	if not corpo.is_on_floor():
		volante = move_toward(volante, 0.0, corpo.stats.friccao * delta)
		corpo.rotation.y += volante * angulo * fator_virada() * delta
		return
	
	volante = move_toward(volante, rotacao, corpo.stats.friccao * delta)
	corpo.rotation.y += volante * angulo * (corpo.velocity.length() / velocidade) * delta
	
	var frente := -corpo.global_basis.z
	pedal = move_toward(pedal, impulso, aceleracao * delta)
	var forca_motor := frente * (pedal * velocidade)
	
	fisica_componente.aplicar_forca(forca_motor)

func fator_virada() -> float:
	var vel_frente := corpo.velocity.dot(-corpo.global_basis.z)
	var t := clampf(absf(vel_frente)/corpo.stats.velocidade, 0.0, 1.0)
	return corpo.stats.fator_virada.sample_baked(t)
