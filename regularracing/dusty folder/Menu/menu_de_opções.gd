extends Control

signal fechou

@onready var slider_musica  = $VBoxContainer/HSliderMusica
@onready var slider_efeitos = $VBoxContainer/HSliderEfeitos
@onready var btn_voltar     = $VBoxContainer/Voltar
@onready var som_menu       = get_node(^"/root/MainMenu/SomMenu")
@onready var mat            = get_node(^"/root/MainMenu/CanvasLayer/BackGround").material

const PAINEL_FORA   := Vector2(0, -1080)
const PAINEL_DENTRO := Vector2(0, 0)
const DURACAO       := 0.6

const CORES := {
	"deep_purple": [Vector3(0.18, 0.03, 0.14), Vector3(0.40, 0.78, 0.72)],
	"aubergine":   [Vector3(0.46, 0.16, 0.32), Vector3(0.45, 0.82, 0.45)],
	"orange_glow": [Vector3(0.91, 0.33, 0.12), Vector3(0.55, 0.90, 0.35)],
}

func _ready() -> void:
	position = PAINEL_FORA
	btn_voltar.pressed.connect(_on_voltar)

func _tween(alvo, ease = Tween.EASE_OUT) -> Tween:
	var t = create_tween().set_ease(ease).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "position", alvo, DURACAO)
	return t

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
