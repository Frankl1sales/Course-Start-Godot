extends CharacterBody2D

var velocidade_cavalo: float = 300.0  # Velocidade do cavalo (ajustável)
var direcao_move: Vector2 = Vector2(1, 1)  # Direção inicial
var janela_tamanho: Vector2  # Tamanho da tela

# Called when the node enters the scene tree for the first time.
func _ready():
	# Obter o tamanho da tela
	janela_tamanho = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Atualiza a posição do cavalo
	position += direcao_move * velocidade_cavalo * delta

	# Verifica os limites da tela e reflete o movimento
	if position.x < 0 or position.x > janela_tamanho.x:
		direcao_move.x *= -1  # Inverte a direção horizontal
	if position.y < 0 or position.y > janela_tamanho.y:
		direcao_move.y *= -1  # Inverte a direção vertical

	# Move o cavalo usando a velocidade calculada
	velocity = direcao_move.normalized() * velocidade_cavalo
	move_and_slide()

func _on_Mago_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch:
		if event.pressed:
			GameManager.verificar_clique("Mago")
			print("Mago clicado!")
	elif event is InputEventMouseButton:
		if event.pressed:
			# Adicione a lógica do clique aqui
			GameManager.verificar_clique("Mago")
			print("Mago clicado!")
