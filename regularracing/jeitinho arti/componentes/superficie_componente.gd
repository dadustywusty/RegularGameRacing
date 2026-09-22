extends ShapeCast3D

var multiplicador_velocidade := 1.0
var multiplicador_aceleraçao := 1.0
var multiplicador_fricçao := 1.0
var pode_drift := true

func tick() -> void:
	if is_colliding():
		var chao = get_collider(0)
		if chao is InformaçaoSuperficie:
			multiplicador_velocidade = chao.dados.multiplicador_velocidade
			multiplicador_aceleraçao = chao.dados.multiplicador_aceleraçao
			multiplicador_fricçao = chao.dados.multiplicador_fricçao
			pode_drift = chao.dados.pode_drift
