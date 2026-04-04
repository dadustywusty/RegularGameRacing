extends Node2D

@onready var btn_jogar  = %Vamo
@onready var btn_opcoes = %"Opeçoes"
@onready var btn_sair   = %"vou embora"
@onready var som_menu   = $SomMenu

@onready var painel_opcoes      = $CanvasLayer/"Menu de opções"
@onready var controle_principal = $CanvasLayer/"Controle principal"


const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER  := Vector2(1.15, 1.15)
const DURACAO       := 0.25

var tweens := {}

func _ready() -> void:
	for btn in [btn_jogar, btn_opcoes, btn_sair]:
		btn.pivot_offset = btn.size / 2.0
		tweens[btn] = null
		btn.mouse_entered.connect(_animar_btn.bind(btn, ESCALA_HOVER))
		btn.mouse_exited.connect(_animar_btn.bind(btn, ESCALA_NORMAL))

	btn_jogar.pressed.connect(_on_vamo_pressed)
	btn_opcoes.pressed.connect(_on_opeçoes_pressed)
	btn_sair.pressed.connect(_on_vou_embora_pressed)

func _animar_btn(no, escala_alvo: Vector2) -> void:
	if escala_alvo == ESCALA_HOVER:
		som_menu.tocar_hover()
	if tweens[no]:
		tweens[no].kill()
	tweens[no] = create_tween()
	tweens[no].set_ease(Tween.EASE_OUT)
	tweens[no].set_trans(Tween.TRANS_BACK)
	tweens[no].tween_property(no, "scale", escala_alvo, DURACAO)

	# compensa a escala no CenterContainer pra o label não crescer
	var container = no.get_child(0)
	var escala_comp = Vector2(1.0 / escala_alvo.x, 1.0 / escala_alvo.y)
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_BACK)
	t.tween_property(container, "scale", escala_comp, DURACAO)

func _on_vamo_pressed() -> void:
	som_menu.tocar_click()
	get_tree().change_scene_to_file("res://dusty folder/Menu/mapas.tscn")

func _on_opeçoes_pressed() -> void:
	som_menu.tocar_click()
	controle_principal.visible = false
	painel_opcoes.abrir()

func _on_vou_embora_pressed() -> void:
	som_menu.tocar_click()
	get_tree().quit()
