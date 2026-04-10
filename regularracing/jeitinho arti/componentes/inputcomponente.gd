extends Node
class_name InputComponente

# esse script lida APENAS com input, ele não vai mexer o personagem por si só

# direção da aceleração, 1 é pra frente, -1 é pra trás
var aceleracao := 0.0
# direção do volante, 1 é pra esquerda, -1 é pra direita
var rotacao := 0.0
var drift : bool
var retrovisor : bool
var item : bool

func _process(_delta: float) -> void:
	aceleracao = 0.0
	aceleracao += Input.get_action_strength("acelerar")
	aceleracao -= Input.get_action_strength("freio")
	rotacao = 0.0
	rotacao += Input.get_action_strength("esquerda")
	rotacao -= Input.get_action_strength("direita")
	
	item = Input.is_action_just_pressed("item")
	retrovisor = Input.is_action_pressed("retrovisor")
	drift = Input.is_action_pressed("drift")
	
	var personagem = get_parent()
	personagem.aceleracao = aceleracao
	personagem.rotacao = rotacao
	personagem.drift = drift
	personagem.pulo = Input.is_action_just_pressed("drift")
	personagem.item_input = item
	personagem.retrovisor = retrovisor
	
