extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

const DURACAO     := 0.5
const TEMPO_PRETO := 0.5
const TEMPO_MIN_ESCURO := 0.8    # tempo mínimo de tela escura (segundos)

func _ready() -> void:
	var tamanho = 3000.0
	rect.size = Vector2(tamanho, tamanho)
	rect.rotation_degrees = 45
	rect.pivot_offset = Vector2(tamanho, tamanho) / 2.0
	rect.position = get_viewport().get_visible_rect().size / 2.0 - rect.pivot_offset
	rect.scale = Vector2.ZERO
	rect.color = Color(0.133, 0.0, 0.145, 1.0)
	rect.visible = false

func transicionar(cena: String) -> void:
	var tempo_inicio := Time.get_ticks_msec()

	# 1. Inicia o carregamento ANTES do fade-out
	ResourceLoader.load_threaded_request(cena)

	# 2. Roda o fade-out (o carregamento continua em paralelo)
	await _fechar()

	# 3. Espera o carregamento terminar (se ainda não terminou)
	var status = ResourceLoader.load_threaded_get_status(cena)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(cena)

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("Transicao: falha ao carregar '%s' (status %d)" % [cena, status])
		_abrir()
		return

	# 4. Garante tempo mínimo de tela escura (evita "piscada" quando carrega rápido)
	var decorrido_ms := Time.get_ticks_msec() - tempo_inicio
	var restante_ms := int(TEMPO_MIN_ESCURO * 1000) - decorrido_ms
	if restante_ms > 0:
		await get_tree().create_timer(restante_ms / 1000.0).timeout

	# 5. Troca a cena
	var cena_carregada: PackedScene = ResourceLoader.load_threaded_get(cena)
	get_tree().change_scene_to_packed(cena_carregada)

	# 6. Espera 2 frames pra nova cena estar 100% pronta
	await get_tree().process_frame
	await get_tree().process_frame

	# 7. Abre a transição (fade-in)
	_abrir()


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
