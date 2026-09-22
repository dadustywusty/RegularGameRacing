extends Node2D

@onready var btn_jogar  = %Vamo
@onready var btn_opcoes = %"Opeçoes"
@onready var btn_sair   = %"vou embora"

const INPUT_DELAY  := 0.18
const INPUT_REPEAT := 0.12

const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER  := Vector2(1.15, 1.15)
const DURACAO_BOTAO := 0.15

var botoes := []
var indice_foco := 0
var _processando := false
var _input_cooldown := 0.0
var tweens := {}
var _mouse_ativo := false

func _ready() -> void:
	Musga.tocar_menu()
	Transicao.rect.scale = Vector2.ONE
	Transicao.rect.visible = true
	Transicao._abrir()
	_animar_gibus()

	botoes = [btn_jogar, btn_opcoes, btn_sair]
	for btn in botoes:
		btn.focus_mode = Control.FOCUS_ALL
		btn.pivot_offset = btn.size / 2.0
		tweens[btn] = null
		btn.focus_entered.connect(_on_foco_entrou)               # ← TOCA SOM
		btn.focus_entered.connect(_animar_btn.bind(btn, ESCALA_HOVER))   # ← ANIMA
		btn.focus_exited.connect(_animar_btn.bind(btn, ESCALA_NORMAL))
		btn.mouse_entered.connect(_on_mouse_entrou.bind(btn))
		btn.mouse_exited.connect(_on_mouse_saiu.bind(btn))
		btn.pressed.connect(_ativar_botao.bind(btn))

	await get_tree().process_frame
	btn_jogar.grab_focus()

func _input(event: InputEvent) -> void:
	# Detecta movimento do mouse
	if event is InputEventMouseMotion:
		if not _mouse_ativo:
			_mouse_ativo = true
			var focado = get_viewport().gui_get_focus_owner()
			if focado:
				focado.release_focus()

	# Detecta uso do controle/teclado
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventKey:
		if _mouse_ativo:
			_mouse_ativo = false
			# Devolve o foco pro botão que estava selecionado
			if indice_foco >= 0 and indice_foco < botoes.size():
				botoes[indice_foco].grab_focus()

func _process(delta: float) -> void:
	if _input_cooldown > 0.0:
		_input_cooldown -= delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	var direcao := 0
	if event.is_action_pressed("menu_cima"):
		direcao = -1
	elif event.is_action_pressed("menu_baixo"):
		direcao = 1

	if direcao != 0:
		if _input_cooldown > 0.0:
			return
		_mover_foco(direcao)
		_input_cooldown = INPUT_DELAY
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("menu_confirmar"):
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
		_animar_btn(btn, ESCALA_HOVER)

func _on_mouse_saiu(btn) -> void:
	if not btn.has_focus():
		_animar_btn(btn, ESCALA_NORMAL)

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

func _animar_btn(no, escala_alvo: Vector2) -> void:
	if tweens[no]:
		tweens[no].kill()
	tweens[no] = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweens[no].tween_property(no, "scale", escala_alvo, DURACAO_BOTAO)

	if no.get_child_count() > 0:
		var filho = no.get_child(0)
		if filho is Control:
			var escala_comp = Vector2(1.0 / escala_alvo.x, 1.0 / escala_alvo.y)
			var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			t.tween_property(filho, "scale", escala_comp, DURACAO_BOTAO)

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
