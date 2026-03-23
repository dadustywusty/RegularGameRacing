extends RayCast3D
class_name TrickComponente

@onready var trick_animaçoes: AnimationPlayer = %TrickAnimaçoes
@onready var turbo: TurboComponente = $"../turbo"

var pode_trick := false
var fez_trick := false

# eu nao renomeei essa função pra "tick" pq ja tem uma função "trick". se nao ia
# confundir. se quiser mudar o nome da segunda função e jogar esse process pra um
# tick no script principal, pode fazer.
func _process(_delta: float) -> void:
	if is_colliding():
		pode_trick = false
	
	if not is_colliding():
		pode_trick = true
		await get_tree().create_timer(0.5).timeout
		pode_trick = false
	
	if fez_trick and is_colliding():
		aplicar_turbo()
		fez_trick = false

func trick() -> void:
	pode_trick = false
	tocar_animacoes()

func tocar_animacoes() -> void:
	var anim = randi() % 2
	if anim == 0:
		trick_animaçoes.play("trick 1")
	elif anim == 1:
		trick_animaçoes.play("trick 2")

func aplicar_turbo() -> void:
	turbo.forca_turbo = 80
	turbo.duracao_turbo = 0.5
	turbo.ativar()
