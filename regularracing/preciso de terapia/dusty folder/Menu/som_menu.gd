extends Node

var hover_player := AudioStreamPlayer.new()
var click_player := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(hover_player)
	add_child(click_player)
	hover_player.stream = preload("res://dusty folder/sound effects/passei o mouse em cima.ogg")
	click_player.stream = preload("res://dusty folder/sound effects/cliquei.ogg")

func tocar_hover() -> void:
	hover_player.play()

func tocar_click() -> void:
	click_player.play()
