extends CharacterBody2D

# Variáveis
var velocidade_cavalo: float = 300.0  # Velocidade do cavalo (ajustável)
var direcao_move: Vector2 = Vector2(1, 1)  # Direção inicial
var janela_tamanho: Vector2  # Tamanho da tela

# Referência ao GameManager
@onready var game_manager = get_node("/root/GameManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Obter o tamanho da tela
	janela_tamanho = get_viewport_rect().size

	# Garantir que o GameManager está disponível
	if game_manager == null:
		print("GameManager não encontrado!")
		return

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

# Função para lidar com o clique no Cavalo
func _on_Cavalo_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch:
		if event.pressed:
			GameManager.verificar_clique("Cavalo")
			print("Cavalo clicado!")
			
	if event is InputEventMouseButton and event.pressed:
		# Adiciona a lógica de clique no Cavalo
		game_manager.verificar_clique("Cavalo")
		print("Cavalo clicado!")
