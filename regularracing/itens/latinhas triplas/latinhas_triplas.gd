extends Node3D

var turbo: TurboComponente
var usos := 3

func configurar(player: CharacterBody3D) -> void:
	turbo = player.turbo

func usar() -> void:
	turbo.forca_turbo = 180
	turbo.duracao_turbo = 1.0
	turbo.ativar()
	if usos == 3:
		%latinha.queue_free()
	if usos == 2:
		%latinha2.queue_free()
