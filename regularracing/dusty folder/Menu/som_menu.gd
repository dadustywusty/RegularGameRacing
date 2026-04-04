extends AudioStreamPlayer

func tocar_hover() -> void:
	stream = preload("res://dusty folder/Menu/UI_Pallet_01.wav.wav")
	play()

func tocar_click() -> void:
	stream = preload("res://dusty folder/Menu/UI_Pallet_02.wav.wav")
	play()
