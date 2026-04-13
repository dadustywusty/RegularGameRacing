extends Node3D

@export var map_icon:Texture

@onready var icon_sprite : Sprite3D = $IconSprite

func _ready() -> void:
	if map_icon:
		icon_sprite.texture = map_icon
