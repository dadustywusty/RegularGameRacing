extends Button

# Configurações de estilo
var original_margin = 0.0
var target_margin = 40.0 # O quanto o botão desliza para a direita

func _ready():
	# Conecta os sinais de mouse
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Define o ponto de pivô no centro para a rotação ficar bonita
	pivot_offset = size / 2

func _on_mouse_entered():
	var tween = create_tween().set_parallel(true)
	# Desliza para a direita
	tween.tween_property(self, "position:x", original_margin + target_margin, 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	# Aumenta um pouco o tamanho
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	# Inclina levemente
	tween.tween_property(self, "rotation_degrees", 2.0, 0.2)

func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	# Volta para o lugar original
	tween.tween_property(self, "position:x", original_margin, 0.2)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.2)
