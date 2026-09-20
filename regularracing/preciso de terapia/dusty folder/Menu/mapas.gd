extends Node2D

@onready var btn_jogar  = find_child("Vamo", true, false)
@onready var btn_voltar = find_child("voltar", true, false)

const INPUT_DELAY  := 0.18
const INPUT_REPEAT := 0.12

const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER  := Vector2(1.15, 1.15)
const DURACAO_BOTAO := 0.15

var botoes := []
var indice_foco := 0
var _processando := false
var _input_cooldown := 0.0
var _mouse_ativo := false
var tweens := {}

func _ready() -> void:
	Transicao.rect.scale = Vector2.ONE
	Transicao.rect.visible = true
	Transicao._abrir()

	if btn_jogar == null:
		print(">>> ERRO: não achou 'Vamo'")
		return
	if btn_voltar == null:
		print(">>> ERRO: não achou 'voltar'")
		return

	botoes = [btn_jogar, btn_voltar]
	for btn in botoes:
		btn.focus_mode = Control.FOCUS_ALL
		btn.pivot_offset = btn.size / 2.0
		tweens[btn] = null
		btn.focus_entered.connect(_on_foco_entrou.bind(btn))
		btn.focus_exited.connect(_animar_btn.bind(btn, ESCALA_NORMAL))
		btn.mouse_entered.connect(_on_mouse_entrou.bind(btn))
		btn.mouse_exited.connect(_on_mouse_saiu.bind(btn))
		btn.pressed.connect(_ativar_botao.bind(btn))

	await get_tree().process_frame
	btn_jogar.grab_focus()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not _mouse_ativo:
			_mouse_ativo = true
			var focado = get_viewport().gui_get_focus_owner()
			if focado:
				focado.release_focus()

	elif event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventKey:
		if _mouse_ativo:
			_mouse_ativo = false
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

func _on_foco_entrou(btn) -> void:
	SomMenu.tocar_hover()
	_animar_btn(btn, ESCALA_HOVER)

func _on_mouse_entrou(btn) -> void:
	if not btn.has_focus():
		SomMenu.tocar_hover()
		_animar_btn(btn, ESCALA_HOVER)

func _on_mouse_saiu(btn) -> void:
	if not btn.has_focus():
		_animar_btn(btn, ESCALA_NORMAL)

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

func _ativar_botao(btn) -> void:
	if _processando:
		return
	_processando = true

	SomMenu.tocar_click()

	match btn.name:
		"Vamo":
			_on_vamo_pressed()
		"voltar":
			_on_voltar_pressed()
		_:
			print(">>> botão desconhecido: ", btn.name)

	await get_tree().process_frame
	_processando = false

func _on_vamo_pressed() -> void:
	Transicao.transicionar("res://pistas/regular circuit/regular_circuit.tscn")

func _on_voltar_pressed() -> void:
	Transicao.transicionar("res://preciso de terapia/dusty folder/Menu/main_menu.tscn")
