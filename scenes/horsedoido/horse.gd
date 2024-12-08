extends CharacterBody2D

var velocidade_cavalo: float = 200.0
var raio_movimento: float = 100.0
var angulo: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angulo += delta  # Aumenta o ângulo ao longo do tempo para fazer o movimento circular
	
	# Calcula a nova posição com base em um círculo
	var deslocamento = Vector2(cos(angulo), sin(angulo)) * raio_movimento
	velocity = deslocamento.normalized() * velocidade_cavalo
	
	# Aplica o movimento
	move_and_slide()
