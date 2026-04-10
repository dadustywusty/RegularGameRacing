extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

const DURACAO    := 0.5
const TEMPO_PRETO := 0.5

func _ready() -> void:
	# força quadrado centralizado em 45 graus
	var tamanho = 3000.0  # grande o suficiente para cobrir tudo
	rect.size = Vector2(tamanho, tamanho)
	rect.rotation_degrees = 45
	rect.pivot_offset = Vector2(tamanho, tamanho) / 2.0
	rect.position = get_viewport().get_visible_rect().size / 2.0 - rect.pivot_offset
	rect.scale = Vector2.ZERO
	rect.color = Color(0.133, 0.0, 0.145, 1.0)
	rect.visible = false

func transicionar(cena: String) -> void:
	await _fechar()
	await get_tree().create_timer(TEMPO_PRETO).timeout
	get_tree().change_scene_to_file(cena)
	await get_tree().process_frame
	await _abrir()

func _fechar() -> void:
	rect.visible = true
	rect.color = Color(0.133, 0.0, 0.145, 1.0)
	rect.scale = Vector2.ZERO
	rect.pivot_offset = rect.size / 2.0
	var t = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	t.tween_property(rect, "scale", Vector2.ONE, DURACAO)
	await t.finished

func _abrir() -> void:
	rect.visible = true
	rect.color = Color(0.133, 0.0, 0.145, 1.0)
	rect.scale = Vector2.ONE
	rect.pivot_offset = rect.size / 2.0
	var t = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_property(rect, "scale", Vector2.ZERO, DURACAO)
	await t.finished
	rect.visible = false
