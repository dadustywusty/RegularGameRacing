extends Control

@onready var engrnagem          = $Engrnagem
@onready var slider_musica      = $VBoxContainer/HSliderMusica
@onready var slider_efeitos     = $VBoxContainer/HSliderEfeitos
@onready var btn_voltar         = $VBoxContainer/Voltar
@onready var engrnagem_base_pos: Vector2 = engrnagem.position

const PASSO_SLIDER  := 5.0
const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER  := Vector2(1.15, 1.15)
const DURACAO_BOTAO := 0.15

var focaveis := []
var indice_foco := 0
var _processando := false
var _mouse_ativo := false
var tweens := {}

func _ready() -> void:
	Transicao.rect.scale = Vector2.ONE
	Transicao.rect.visible = true
	Transicao._abrir()
	_animar_engrnagem()

	# Botão voltar — animação de foco + mouse
	btn_voltar.focus_mode = Control.FOCUS_ALL
	btn_voltar.pivot_offset = btn_voltar.size / 2.0
	tweens[btn_voltar] = null
	btn_voltar.focus_entered.connect(_on_foco_entrou_btn)
	btn_voltar.focus_exited.connect(_animar_btn.bind(btn_voltar, ESCALA_NORMAL))
	btn_voltar.mouse_entered.connect(_on_mouse_entrou_btn)
	btn_voltar.mouse_exited.connect(_on_mouse_saiu_btn)
	btn_voltar.pressed.connect(_on_voltar)

	# Sliders — só som de hover (sem escala, porque são HSlider)
	slider_musica.focus_mode  = Control.FOCUS_ALL
	slider_efeitos.focus_mode = Control.FOCUS_ALL
	slider_musica.focus_entered.connect(_on_foco_entrou)
	slider_efeitos.focus_entered.connect(_on_foco_entrou)

	focaveis = [slider_musica, slider_efeitos, btn_voltar]

	slider_musica.value  = _db_para_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")))
	slider_efeitos.value = _db_para_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Efeitos")))
	slider_musica.value_changed.connect(_on_musica_mudou)
	slider_efeitos.value_changed.connect(_on_efeitos_mudou)

	await get_tree().process_frame
	slider_musica.grab_focus()

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
			if indice_foco >= 0 and indice_foco < focaveis.size():
				focaveis[indice_foco].grab_focus()

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
		var focado = get_viewport().gui_get_focus_owner()
		if focado == btn_voltar:
			_ativar_voltar()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu_esquerda"):
		_ajustar_slider(-PASSO_SLIDER)
	elif event.is_action_pressed("menu_direita"):
		_ajustar_slider(PASSO_SLIDER)

func _mover_foco(direcao: int) -> void:
	var focado = get_viewport().gui_get_focus_owner()
	var idx_atual = focaveis.find(focado)
	if idx_atual != -1:
		indice_foco = idx_atual
	indice_foco = wrapi(indice_foco + direcao, 0, focaveis.size())
	focaveis[indice_foco].grab_focus()

func _ajustar_slider(delta: float) -> void:
	var atual = get_viewport().gui_get_focus_owner()
	if atual == slider_musica or atual == slider_efeitos:
		atual.value = clamp(atual.value + delta, atual.min_value, atual.max_value)

func _on_foco_entrou() -> void:
	SomMenu.tocar_hover()

func _on_foco_entrou_btn() -> void:
	SomMenu.tocar_hover()
	_animar_btn(btn_voltar, ESCALA_HOVER)

func _on_mouse_entrou_btn() -> void:
	if not btn_voltar.has_focus():
		SomMenu.tocar_hover()
		_animar_btn(btn_voltar, ESCALA_HOVER)

func _on_mouse_saiu_btn() -> void:
	if not btn_voltar.has_focus():
		_animar_btn(btn_voltar, ESCALA_NORMAL)

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

func _ativar_voltar() -> void:
	if _processando:
		return
	_processando = true
	_on_voltar()
	await get_tree().process_frame
	_processando = false

func _on_musica_mudou(valor: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica"), _slider_para_db(valor))

func _on_efeitos_mudou(valor: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Efeitos"), _slider_para_db(valor))

func _slider_para_db(valor: float) -> float:
	return linear_to_db(valor / 100.0)

func _db_para_slider(db: float) -> float:
	return db_to_linear(db) * 100.0

func _on_voltar() -> void:
	SomMenu.tocar_click()
	Transicao.transicionar("res://preciso de terapia/dusty folder/Menu/main_menu.tscn")

func _animar_engrnagem() -> void:
	var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(engrnagem, "position", engrnagem_base_pos + Vector2(0, 12), 1.8)
	t.tween_property(engrnagem, "position", engrnagem_base_pos, 1.8)
	await t.finished
	_animar_engrnagem()
