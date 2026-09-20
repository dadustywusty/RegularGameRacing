extends Node2D

@onready var btn_jogar  = %Vamo
@onready var btn_opcoes = %"Opeçoes"
@onready var btn_sair   = %"vou embora"

var botoes := []
var indice_foco := 0
var _processando := false

func _ready() -> void:
	Transicao.rect.scale = Vector2.ONE
	Transicao.rect.visible = true
	Transicao._abrir()
	_animar_gibus()

	botoes = [btn_jogar, btn_opcoes, btn_sair]
	for btn in botoes:
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_entered.connect(_on_foco_entrou)
		btn.mouse_entered.connect(_on_mouse_entrou.bind(btn))
		btn.pressed.connect(_ativar_botao.bind(btn))

	await get_tree().process_frame
	btn_jogar.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	if event.is_action_pressed("menu_cima"):
		_mover_foco(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu_baixo"):
		_mover_foco(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu_confirmar"):
		var btn_focado = get_viewport().gui_get_focus_owner()
		if btn_focado and btn_focado in botoes:
			_ativar_botao(btn_focado)
		get_viewport().set_input_as_handled()

func _mover_foco(direcao: int) -> void:
	var btn_focado = get_viewport().gui_get_focus_owner()
	var idx_atual = botoes.find(btn_focado)
	if idx_atual != -1:
		indice_foco = idx_atual
	indice_foco = wrapi(indice_foco + direcao, 0, botoes.size())
	botoes[indice_foco].grab_focus()

func _on_foco_entrou() -> void:
	SomMenu.tocar_hover()

func _on_mouse_entrou(btn) -> void:
	if not btn.has_focus():
		SomMenu.tocar_hover()

func _ativar_botao(btn) -> void:
	if _processando:
		return
	_processando = true

	SomMenu.tocar_click()

	match btn.name:
		"Vamo":
			_on_vamo_pressed()
		"Opeçoes":
			_on_opeçoes_pressed()
		"vou embora":
			_on_vou_embora_pressed()
		_:
			print(">>> botão desconhecido: ", btn.name)

	await get_tree().process_frame
	_processando = false

func _on_vamo_pressed() -> void:
	Transicao.transicionar("res://dusty folder/Menu/mapas.tscn")

func _on_opeçoes_pressed() -> void:
	Transicao.transicionar("res://preciso de terapia/dusty folder/Menu/menu_de_opções.tscn")

func _on_vou_embora_pressed() -> void:
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

@onready var gibus = $"CanvasLayer/Controle principal/VBoxContainer/Gibus"

func _animar_gibus() -> void:
	var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(gibus, "position", gibus.position + Vector2(0, 12), 1.8)
	t.tween_property(gibus, "position", gibus.position, 1.8)
	await t.finished
	_animar_gibus()
