extends Control

@onready var btn_voltar = %Vamo

const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER  := Vector2(1.15, 1.15)
const DURACAO       := 0.25

var tween_escala: Tween

func _ready() -> void:
	# ❌ REMOVIDO: Transicao.rect.scale, visible, _abrir()
	# O Transicao.transicionar() já cuida disso

	if btn_voltar:
		btn_voltar.pivot_offset = btn_voltar.size / 2.0
		btn_voltar.focus_mode = Control.FOCUS_ALL
		btn_voltar.mouse_entered.connect(_on_mouse_entrou)
		btn_voltar.mouse_exited.connect(_on_mouse_saiu)
		btn_voltar.pressed.connect(_on_botao_pressionado)
		btn_voltar.grab_focus()
	else:
		print(">>> ERRO: Botão %Vamo não encontrado no acabou.tscn")

func _on_mouse_entrou() -> void:
	SomMenu.tocar_hover()
	_animar_hover(true)

func _on_mouse_saiu() -> void:
	_animar_hover(false)

func _animar_hover(ativar: bool) -> void:
	var escala_alvo = ESCALA_HOVER if ativar else ESCALA_NORMAL

	if tween_escala:
		tween_escala.kill()

	tween_escala = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_escala.tween_property(btn_voltar, "scale", escala_alvo, DURACAO)

	if btn_voltar.get_child_count() > 0:
		var filho = btn_voltar.get_child(0)
		if filho is Control:
			var escala_comp = Vector2(1.0 / escala_alvo.x, 1.0 / escala_alvo.y)
			var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			t.tween_property(filho, "scale", escala_comp, DURACAO)

func _on_botao_pressionado() -> void:
	SomMenu.tocar_click()
	Transicao.transicionar("res://preciso de terapia/dusty folder/Menu/main_menu.tscn")
