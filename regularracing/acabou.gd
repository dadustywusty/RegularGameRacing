extends Control

@onready var btn_voltar  = %Vamo
@onready var label_tempo = $VBoxContainer/LabelTempo

const ESCALA_NORMAL := Vector2(1.0, 1.0)
const ESCALA_HOVER  := Vector2(1.15, 1.15)
const DURACAO       := 0.25

var tween_escala: Tween
var _processando := false

func _ready() -> void:
	_atualizar_tempo()
	
	if btn_voltar:
		btn_voltar.pivot_offset = btn_voltar.size / 2.0
		btn_voltar.focus_mode = Control.FOCUS_ALL
		btn_voltar.mouse_entered.connect(_on_mouse_entrou)
		btn_voltar.mouse_exited.connect(_on_mouse_saiu)
		btn_voltar.pressed.connect(_on_botao_pressionado)
		
		await get_tree().process_frame
		btn_voltar.grab_focus()

func _atualizar_tempo() -> void:
	var tempo = DadosCorrida.tempo_final
	
	if label_tempo:
		label_tempo.text = "Tempo: %s" % _formatar_tempo(tempo)

func _formatar_tempo(tempo: float) -> String:
	var minutos: int = int(tempo / 60.0) % 60
	var segundos: int = int(tempo) % 60
	var ms: int = int(tempo * 1000.0) % 1000
	
	if minutos > 0:
		return "%d:%02d.%03d" % [minutos, segundos, ms]
	return "%02d.%03d" % [segundos, ms]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event.is_action_pressed("menu_confirmar"):
		if btn_voltar and btn_voltar.has_focus():
			_ativar_voltar()
			get_viewport().set_input_as_handled()

func _ativar_voltar() -> void:
	if _processando:
		return
	_processando = true
	_on_botao_pressionado()
	await get_tree().process_frame
	_processando = false

func _on_mouse_entrou() -> void:
	SomMenu.tocar_hover()
	_animar_hover(true)

func _on_mouse_saiu() -> void:
	_animar_hover(false)

func _animar_hover(ativar: bool) -> void:
	if btn_voltar == null:
		return
	var escala_alvo = ESCALA_HOVER if ativar else ESCALA_NORMAL
	if tween_escala:
		tween_escala.kill()
	tween_escala = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_escala.tween_property(btn_voltar, "scale", escala_alvo, DURACAO)

func _on_botao_pressionado() -> void:
	SomMenu.tocar_click()
	DadosCorrida.limpar()
	Transicao.transicionar("res://preciso de terapia/dusty folder/Menu/main_menu.tscn")
