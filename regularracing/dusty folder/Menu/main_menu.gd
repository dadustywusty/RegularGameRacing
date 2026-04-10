extends Node2D

@onready var btn_jogar          = %Vamo
@onready var btn_opcoes         = %"Opeçoes"
@onready var btn_sair           = %"vou embora"
@onready var som_menu           = $SomMenu
@onready var painel_opcoes      = $CanvasLayer/"Menu de opções"
@onready var controle_principal = $CanvasLayer/"Controle principal"

const ESCALA_NORMAL  := Vector2(1.0, 1.0)
const ESCALA_HOVER   := Vector2(1.15, 1.15)
const POSICAO_NORMAL := Vector2(0, 0)
const POSICAO_FORA   := Vector2(0, 1080)
const DURACAO        := 0.25
const DURACAO_MENU   := 0.6

var tweens := {}

func _ready() -> void:
	_animar_gibus()
	painel_opcoes.fechou.connect(_on_opcoes_fechou)
	for btn in [btn_jogar, btn_opcoes, btn_sair]:
		btn.pivot_offset = btn.size / 2.0
		tweens[btn] = null
		btn.mouse_entered.connect(_animar_btn.bind(btn, ESCALA_HOVER))
		btn.mouse_exited.connect(_animar_btn.bind(btn, ESCALA_NORMAL))
	btn_jogar.pressed.connect(_on_vamo_pressed)
	btn_opcoes.pressed.connect(_on_opeçoes_pressed)
	btn_sair.pressed.connect(_on_vou_embora_pressed)

func _tween(no, propriedade, alvo, duracao, tipo_ease = Tween.EASE_OUT, trans = Tween.TRANS_CUBIC) -> Tween:
	var t = create_tween().set_ease(tipo_ease).set_trans(trans)
	t.tween_property(no, propriedade, alvo, duracao)
	return t

func _animar_btn(no, escala_alvo: Vector2) -> void:
	if escala_alvo == ESCALA_HOVER:
		som_menu.tocar_hover()
	if tweens[no]:
		tweens[no].kill()
	tweens[no] = _tween(no, "scale", escala_alvo, DURACAO, Tween.EASE_OUT, Tween.TRANS_BACK)
	var escala_comp = Vector2(1.0 / escala_alvo.x, 1.0 / escala_alvo.y)
	_tween(no.get_child(0), "scale", escala_comp, DURACAO, Tween.EASE_OUT, Tween.TRANS_BACK)

func _animar_painel(no, alvo, tipo_ease = Tween.EASE_OUT) -> Tween:
	return _tween(no, "position", alvo, DURACAO_MENU, tipo_ease, Tween.TRANS_CUBIC)

func _on_opcoes_fechou() -> void:
	controle_principal.visible = true
	controle_principal.position = POSICAO_FORA
	_animar_painel(controle_principal, POSICAO_NORMAL)

func _on_opeçoes_pressed() -> void:
	som_menu.tocar_click()
	await _animar_painel(controle_principal, POSICAO_FORA, Tween.EASE_IN).finished
	controle_principal.visible = false
	painel_opcoes.abrir()

func _on_vamo_pressed() -> void:
	som_menu.tocar_click()
	Transicao.transicionar("res://dusty folder/Menu/mapas.tscn")

func _on_vou_embora_pressed() -> void:
	som_menu.tocar_click()
	get_tree().quit()

#67

#animação que eu decidir fazer agora e eu to com precisa de arrumar
@onready var gibus = $"CanvasLayer/Controle principal/VBoxContainer/Gibus"

func _animar_gibus() -> void:
	var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(gibus, "position", gibus.position + Vector2(0, 12), 1.8)
	t.tween_property(gibus, "position", gibus.position, 1.8)
	await t.finished
	_animar_gibus()
