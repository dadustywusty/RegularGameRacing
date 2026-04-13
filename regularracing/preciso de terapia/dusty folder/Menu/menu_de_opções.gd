extends Control
signal fechou

@onready var engrnagem = $Engrnagem
@onready var slider_musica  = $VBoxContainer/HSliderMusica
@onready var slider_efeitos = $VBoxContainer/HSliderEfeitos
@onready var btn_voltar     = $VBoxContainer/Voltar
@onready var som_menu       = get_node(^"/root/MainMenu/SomMenu")
@onready var mat            = get_node(^"/root/MainMenu/CanvasLayer/BackGround").material

const PAINEL_FORA   := Vector2(0, -1080)
const PAINEL_DENTRO := Vector2(0, 0)
const DURACAO       := 0.6
const ESCALA_NORMAL  := Vector2(1.0, 1.0)
const ESCALA_HOVER   := Vector2(1.15, 1.15)
const DURACAO_BOTAO  := 0.25

const CORES := {
	"deep_purple": [Vector3(0.18, 0.03, 0.14), Vector3(0.40, 0.78, 0.72)],
	"aubergine":   [Vector3(0.46, 0.16, 0.32), Vector3(0.45, 0.82, 0.45)],
	"orange_glow": [Vector3(0.91, 0.33, 0.12), Vector3(0.55, 0.90, 0.35)],
}

var tween_btn_voltar: Tween = null
var _pos_base_engrnagem: Vector2

func _animar_engrnagem() -> void:
	var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(engrnagem, "position", _pos_base_engrnagem + Vector2(0, 12), 1.8)
	t.tween_property(engrnagem, "position", _pos_base_engrnagem, 1.8)
	await t.finished
	_animar_engrnagem()

func _ready() -> void:
	position = PAINEL_FORA
	_pos_base_engrnagem = engrnagem.position
	_animar_engrnagem()
	
	# Configurar botão voltar com animações
	btn_voltar.pivot_offset = btn_voltar.size / 2.0
	btn_voltar.mouse_entered.connect(_animar_btn_voltar.bind(ESCALA_HOVER))
	btn_voltar.mouse_exited.connect(_animar_btn_voltar.bind(ESCALA_NORMAL))
	btn_voltar.pressed.connect(_on_voltar)
	
	slider_musica.value  = _db_para_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")))
	slider_efeitos.value = _db_para_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Efeitos")))
	slider_musica.value_changed.connect(_on_musica_mudou)
	slider_efeitos.value_changed.connect(_on_efeitos_mudou)

func _on_musica_mudou(valor: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica"), _slider_para_db(valor))

func _on_efeitos_mudou(valor: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Efeitos"), _slider_para_db(valor))

func _slider_para_db(valor: float) -> float:
	return linear_to_db(valor / 100.0)

func _db_para_slider(db: float) -> float:
	return db_to_linear(db) * 100.0

func _tween(alvo, tipo_ease = Tween.EASE_OUT) -> Tween:
	var t = create_tween().set_ease(tipo_ease).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "position", alvo, DURACAO)
	return t

func _tween_botao(no, propriedade, alvo, duracao, tipo_ease = Tween.EASE_OUT, trans = Tween.TRANS_CUBIC) -> Tween:
	var t = create_tween().set_ease(tipo_ease).set_trans(trans)
	t.tween_property(no, propriedade, alvo, duracao)
	return t

func _animar_btn_voltar(escala_alvo: Vector2) -> void:
	if escala_alvo == ESCALA_HOVER:
		som_menu.tocar_hover()
	
	if tween_btn_voltar:
		tween_btn_voltar.kill()
	
	tween_btn_voltar = _tween_botao(btn_voltar, "scale", escala_alvo, DURACAO_BOTAO, Tween.EASE_OUT, Tween.TRANS_BACK)
	var escala_comp = Vector2(1.0 / escala_alvo.x, 1.0 / escala_alvo.y)
	_tween_botao(btn_voltar.get_child(0), "scale", escala_comp, DURACAO_BOTAO, Tween.EASE_OUT, Tween.TRANS_BACK)

func abrir() -> void:
	_transicionar_shader(true)
	_tween(PAINEL_DENTRO)

func _on_voltar() -> void:
	som_menu.tocar_click()
	_transicionar_shader(false)
	await _tween(PAINEL_FORA, Tween.EASE_IN).finished
	emit_signal("fechou")

func _transicionar_shader(para_opcoes: bool) -> void:
	var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR).set_parallel(true)
	for param in CORES:
		t.tween_method(
			func(v: Vector3): mat.set_shader_parameter(param, v),
			mat.get_shader_parameter(param),
			CORES[param][1 if para_opcoes else 0],
			DURACAO)

func get_volume_musica() -> float: return slider_musica.value
func get_volume_efeitos() -> float: return slider_efeitos.value
