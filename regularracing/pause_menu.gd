extends CanvasLayer

@onready var btn_continuar = $VBoxContainer/BtnContinuar
@onready var btn_reiniciar = $VBoxContainer/BtnReiniciar
@onready var btn_sair      = $VBoxContainer/BtnSair

const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER  := Vector2(1.15, 1.15)
const DURACAO_BOTAO := 0.15

var botoes := []
var indice_foco := 0
var _processando := false
var tweens := {}
var _mouse_ativo := false
var _pausado := false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	botoes = [btn_continuar, btn_reiniciar, btn_sair]
	for btn in botoes:
		btn.focus_mode = Control.FOCUS_ALL
		btn.pivot_offset = btn.size / 2.0
		tweens[btn] = null
		btn.focus_entered.connect(_on_foco_entrou)
		btn.focus_entered.connect(_animar_btn.bind(btn, ESCALA_HOVER))
		btn.focus_exited.connect(_animar_btn.bind(btn, ESCALA_NORMAL))
		btn.mouse_entered.connect(_on_mouse_entrou.bind(btn))
		btn.mouse_exited.connect(_on_mouse_saiu.bind(btn))
		btn.pressed.connect(_ativar_botao.bind(btn))

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	# Abre/fecha o pause
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		if _pausado:
			_fechar_pause()
		else:
			_abrir_pause()
		get_viewport().set_input_as_handled()
		return
	
	if not _pausado:
		return
	
	var direcao := 0
	if event.is_action_pressed("menu_cima"):
		direcao = -1
	elif event.is_action_pressed("menu_baixo"):
		direcao = 1
	
	if direcao != 0:
		_mover_foco(direcao)
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("menu_confirmar"):
		var btn_focado = get_viewport().gui_get_focus_owner()
		if btn_focado and btn_focado in botoes:
			_ativar_botao(btn_focado)
		get_viewport().set_input_as_handled()

func _abrir_pause() -> void:
	_pausado = true
	visible = true
	get_tree().paused = true
	
	indice_foco = 0
	await get_tree().process_frame
	btn_continuar.grab_focus()

func _fechar_pause() -> void:
	_pausado = false
	visible = false
	get_tree().paused = false

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
		"BtnContinuar":
			_on_continuar()
		"BtnReiniciar":
			_on_reiniciar()
		"BtnSair":
			_on_sair()
	
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

func _on_continuar() -> void:
	_fechar_pause()

func _on_reiniciar() -> void:
	# Despausa ANTES de recarregar (senão a nova cena começa pausada)
	get_tree().paused = false
	# Guarda a cena atual
	var cena_atual = get_tree().current_scene.scene_file_path
	# Recarrega via Transicao
	Transicao.transicionar(cena_atual)

func _on_sair() -> void:
	get_tree().paused = false
	Transicao.transicionar("res://preciso de terapia/dusty folder/Menu/main_menu.tscn")
