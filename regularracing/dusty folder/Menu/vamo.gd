extends Button

@onready var label = $Label

# Defina as cores aqui de acordo com seu fundo do Ubuntu
var cor_texto_sem_fundo = Color("ffffff") # Branco (quando está flutuando)
var cor_texto_com_fundo = Color("300a24") # Roxo Escuro (quando a tarja aparece)

func _ready():
	# Garante que começa com a cor clara
	label.add_theme_color_override("font_color", cor_texto_sem_fundo)
	# Centraliza o pivô para a animação
	pivot_offset = size / 2

func _on_mouse_entered():
	# 1. Muda a cor do texto para escuro (para contrastar com a tarja que surgiu)
	label.add_theme_color_override("font_color", cor_texto_com_fundo)
	
	# 2. Animação de escala e posição (efeito Persona)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", 20.0, 0.1).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited():
	# 1. Volta o texto para branco
	label.add_theme_color_override("font_color", cor_texto_sem_fundo)
	
	# 2. Volta o botão para o lugar
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", 0.0, 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
