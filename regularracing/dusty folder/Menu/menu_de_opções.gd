extends Control

signal fechou

@onready var slider_musica  = $VBoxContainer/HSliderMusica
@onready var slider_efeitos = $VBoxContainer/HSliderEfeitos
@onready var btn_voltar     = $VBoxContainer/Voltar

@export var background: NodePath 

const PAINEL_FORA   := Vector2(0, -1080)
const PAINEL_DENTRO := Vector2(0, 0)
const DURACAO       := 0.6

# cores normais
const DEEP_PURPLE_NORMAL := Vector3(0.18, 0.03, 0.14)
const AUBERGINE_NORMAL   := Vector3(0.46, 0.16, 0.32)
const ORANGE_NORMAL      := Vector3(0.91, 0.33, 0.12)

# cores azuis
const DEEP_PURPLE_OPCOES := Vector3(0.40, 0.78, 0.72)  # verde água (canto)
const AUBERGINE_OPCOES   := Vector3(0.45, 0.82, 0.45)  # verde médio
const ORANGE_OPCOES      := Vector3(0.55, 0.90, 0.35)  # verde vibrante (centro)

func _ready() -> void:
	position = PAINEL_FORA
	btn_voltar.pressed.connect(_on_voltar)

func abrir() -> void:
	_transicionar_shader(true)
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "position", PAINEL_DENTRO, DURACAO)

func _on_voltar() -> void:
	_transicionar_shader(false)
	var t = create_tween()
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "position", PAINEL_FORA, DURACAO)
	await t.finished
	emit_signal("fechou")

func _transicionar_shader(para_opcoes: bool) -> void:
	var mat = get_node(^"/root/MainMenu/CanvasLayer/BackGround").material
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_LINEAR)
	t.set_parallel(true)
	t.tween_method(
		func(v: Vector3): mat.set_shader_parameter("deep_purple", v),
		mat.get_shader_parameter("deep_purple"),
		DEEP_PURPLE_OPCOES if para_opcoes else DEEP_PURPLE_NORMAL, DURACAO)
	t.tween_method(
		func(v: Vector3): mat.set_shader_parameter("aubergine", v),
		mat.get_shader_parameter("aubergine"),
		AUBERGINE_OPCOES if para_opcoes else AUBERGINE_NORMAL, DURACAO)
	t.tween_method(
		func(v: Vector3): mat.set_shader_parameter("orange_glow", v),
		mat.get_shader_parameter("orange_glow"),
		ORANGE_OPCOES if para_opcoes else ORANGE_NORMAL, DURACAO)

func get_volume_musica() -> float:
	return slider_musica.value

func get_volume_efeitos() -> float:
	return slider_efeitos.value
