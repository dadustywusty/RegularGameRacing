extends NavigationAgent3D
class_name IAComponente

@onready var respawn_componente: RespawnComponente = %RespawnComponente

@onready var personagem = get_parent()

var aceleracao := 0.0
var rotacao := 0.0
var drift : bool
var item : bool

var checkpoints := []
var proximo_checkpoint := 0

func _ready() -> void:
	checkpoints = $"../../checkpoints".get_children()
	definir_proximo_checkpoint()

func _process(delta: float) -> void:
	var checkpoint_atual = respawn_componente.checkpoint_atual
	var index = checkpoints.find(checkpoint_atual)
	if index != -1 and index == proximo_checkpoint:
		proximo_checkpoint = (index + 1) % checkpoints.size()
		definir_proximo_checkpoint()
	
	if not is_navigation_finished():
		var proxima_pos = get_next_path_position()
		var alvo = personagem.to_local(proxima_pos).normalized()
		
		rotacao = clamp(-alvo.x * 2.0, -1.0, 1.0)
		var angulo_curva = abs(alvo.x)
		if angulo_curva > 0.8:
			drift = true
		elif angulo_curva < 0.6:
			drift = false
		
		aceleracao = 1.0
	
	var timer_item := 0.0
	if timer_item == 0.0:
		item = true
		timer_item = randf_range(5, 20)
	else:
		item = false
		timer_item -= delta
	
	personagem.aceleracao = aceleracao
	personagem.rotacao = rotacao
	personagem.drift = drift
	personagem.item_input = item

func definir_proximo_checkpoint() -> void:
	target_position = checkpoints[proximo_checkpoint].global_position
