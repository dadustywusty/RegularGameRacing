extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

const DURACAO_ENTRADA := 0.3
const DURACAO_SAIDA   := 0.5

func _ready() -> void:
	rect.color = Color(0, 0, 0, 1)
	rect.visible = true
	var t = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(rect, "color", Color(0, 0, 0, 0), DURACAO_SAIDA)
	await t.finished
	rect.visible = false

func transicionar(cena: String) -> void:
	rect.color = Color(0, 0, 0, 0)
	rect.visible = true
	var t_in = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t_in.tween_property(rect, "color", Color(0, 0, 0, 1), DURACAO_ENTRADA)
	await t_in.finished
	get_tree().change_scene_to_file(cena)
	await get_tree().process_frame
	var t_out = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t_out.tween_property(rect, "color", Color(0, 0, 0, 0), DURACAO_SAIDA)
	await t_out.finished
	rect.visible = false
