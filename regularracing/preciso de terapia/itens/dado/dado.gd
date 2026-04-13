extends Node3D

@export var tempo_respawn: float = 3.0
@export var velocidade_quebra: float = 0.1
@export var velocidade_respawn: float = 0.4

@onready var dado: Node3D = $Dado
@onready var area: Area3D = $Area3D
@onready var particula: GPUParticles3D = $GPUParticles3D
@onready var som: AudioStreamPlayer2D = $BreakingBad

var _quebrado: bool = false
var _escala_original: Vector3

func _ready() -> void:
	area.body_entered.connect(_ao_colidir)
	_escala_original = dado.scale

func _ao_colidir(body: Node3D) -> void:
	if _quebrado:
		return
	if not body is CharacterBody3D:
		return
	_quebrar(body)

func _quebrar(player: CharacterBody3D) -> void:
	_quebrado = true
	area.set_deferred("monitoring", false)
	particula.emitting = true
	
	# 🔊 evita som duplicado
	if not som.playing:
		som.play()

	var tween = create_tween()
	tween.tween_property(dado, "scale", Vector3.ZERO, velocidade_quebra)
	await tween.finished

	# som de pegar item
	if player.has_node("som_item"):
		player.get_node("som_item").play()

	# delay antes de dar o item
	await get_tree().create_timer(1.5).timeout

	if not player.tem_item:
		var item_dicionario = player.get_node("ItemComponente").itens
		var item_novo = item_dicionario.keys().pick_random()
		player.receber_item(item_dicionario[item_novo].instantiate())

	await get_tree().create_timer(tempo_respawn).timeout
	_respawnar()

func _respawnar() -> void:
	_quebrado = false
	dado.scale = Vector3.ZERO
	
	var tween = create_tween()
	tween.tween_property(dado, "scale", _escala_original, velocidade_respawn)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

	await tween.finished
	area.set_deferred("monitoring", true)
