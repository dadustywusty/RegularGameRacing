extends AudioStreamPlayer

func tocar_hover() -> void:
	stream = preload("res://dusty folder/sound effects/passei o mouse em cima.ogg")
	play()

func tocar_click() -> void:
	stream = preload("res://dusty folder/sound effects/cliquei.ogg")
	play()
