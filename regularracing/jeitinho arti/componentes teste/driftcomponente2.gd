extends Node
class_name DriftComponente2

@export var corpo: CharacterBody3D
@export var modelo: Node3D
#@onready var turbo: TurboComponente = $"../turbo"

#var som_drift: AudioStreamPlayer3D
#var pitch := [0.8, 1.1, 1.4]

var nivel :=[0.8, 1.6, 3.0]
var timer: float = 0.0

var drift := false
var pegou_direcao := false
var direcao := 0.0
var angulo_atual := 0.0
var input_direcao := 0.0

var angulo_original : float
var friccao_original : float

func _ready() -> void:
	angulo_original = corpo.stats.angulo_virada
	friccao_original = corpo.stats.friccao

func tick(delta: float) -> void:
	if not drift:
		terminar_drift()
		return
	if not pegou_direcao and input_direcao != 0:
		direcao = sign(input_direcao)
		comecar_drift()
		pegou_direcao = true
	
	if pegou_direcao:
		timer += delta
		
		

func comecar_drift() -> void:
	corpo.friccao -= corpo.stats.fator_drift
	corpo.angulo_virada += corpo.stats.fator_drift * 0.5

func terminar_drift() -> void:
	if not pegou_direcao:
		return
	corpo.friccao = corpo.stats.friccao
	corpo.angulo_virada = corpo.stats.angulo_virada
	timer = 0.0
	drift = false
	pegou_direcao = false

func filtrar_input(input: float) -> float:
	if not pegou_direcao:
		return input
	var t := (input * direcao + 1.0) * 0.5
	return direcao * lerpf(0.5, 1.5, t)



#func calcular_nivel() -> int:
	#var n := 0
	#for i in nivel:
		#if timer >= i:
			#n += 1
	#return n

#func _tocar_som() -> void:
	#if som_drift and calcular_nivel() > 0:
		#som_drift.pitch_scale = [0, pitch[0], pitch[1], pitch[2]][calcular_nivel()]
		#som_drift.play()

#func _ativar_turbo(nivel: int) -> void:
	#match nivel:
		#1: turbo.forca_turbo = 35; turbo.duracao_turbo = 0.3
		#2: turbo.forca_turbo = 75; turbo.duracao_turbo = 0.6
		#3: turbo.forca_turbo = 110; turbo.duracao_turbo = 1.0
	#turbo.ativar()
