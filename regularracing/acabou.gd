extends Node2D

@onready var btn_voltar = %Vamo  # Ajuste o nome se for diferente
@onready var som_menu = get_node_or_null("/root/MainMenu/SomMenu")

const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER := Vector2(1.15, 1.15)
const DURACAO := 0.25

var tween_escala: Tween

func _ready() -> void:
	Transicao.rect.scale = Vector2.ONE
	Transicao.rect.visible = true
	Transicao._abrir()	# Configura o botão com animação
	if btn_voltar:
		btn_voltar.pivot_offset = btn_voltar.size / 2.0
		btn_voltar.mouse_entered.connect(_on_mouse_entrou)
		btn_voltar.mouse_exited.connect(_on_mouse_saiu)
		btn_voltar.pressed.connect(_on_botao_pressionado)
	else:
		print("⚠️ Botão não encontrado! Verifique o nome.")

func _on_mouse_entrou() -> void:
	"""Ao passar o mouse no botão"""
	_animar_hover(true)
	if som_menu and som_menu.has_method("tocar_hover"):
		som_menu.tocar_hover()

func _on_mouse_saiu() -> void:
	"""Ao sair o mouse do botão"""
	_animar_hover(false)

func _animar_hover(ativar: bool) -> void:
	"""Anima o botão aumentando ou diminuindo"""
	var escala_alvo = ESCALA_HOVER if ativar else ESCALA_NORMAL
	
	# Cancela tween anterior
	if tween_escala:
		tween_escala.kill()
	
	# Cria tween para o botão
	tween_escala = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_escala.tween_property(btn_voltar, "scale", escala_alvo, DURACAO)
	
	# Anima o texto filho em escala inversa (se tiver)
	if btn_voltar.get_child_count() > 0:
		var filho = btn_voltar.get_child(0)
		if filho is Control:
			var escala_comp = Vector2(1.0 / escala_alvo.x, 1.0 / escala_alvo.y)
			var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			t.tween_property(filho, "scale", escala_comp, DURACAO)

func _on_botao_pressionado() -> void:
	"""Ao clicar no botão"""
	if som_menu and som_menu.has_method("tocar_click"):
		som_menu.tocar_click()
	
	# Volta ao menu principal
	if Transicao:
		Transicao.transicionar("res://preciso de terapia/dusty folder/Menu/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://preciso de terapia/dusty folder/Menu/main_menu.tscn")
