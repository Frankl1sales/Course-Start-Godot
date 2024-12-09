extends Node2D

# Variáveis
var alvo_atual: String = ""  # Nome do personagem-alvo ("Mago" ou "Cavalo")
var pontos: int = 0  # Pontuação do jogador

# Referências
@onready var mago = $mago_doido
@onready var mago_area = $Mago/Area2D  # Supondo que o Mago seja um nó Area2D
@onready var cavalo = $Cavalo
@onready var image_alvo = $UI/ImageAlvo
@onready var label_pontos = $UI/LabelPontos

# Texturas para os alvos
@export var textura_mago: Texture
@export var textura_cavalo: Texture

# Quando o jogo inicia
func _ready():
	# Certifique-se de que os nós estão na árvore antes de conectar sinais
	
	# Configurar o primeiro alvo
	atualizar_alvo()

# Atualizar o personagem-alvo
func atualizar_alvo():
	# Escolhe aleatoriamente entre "Mago" e "Cavalo"
	alvo_atual = ["Mago", "Cavalo"].pick_random()
	
	# Atualiza a imagem do alvo
	if alvo_atual == "Mago":
		image_alvo.texture = textura_mago
	elif alvo_atual == "Cavalo":
		image_alvo.texture = textura_cavalo

# Detectar cliques nos personagens
func verificar_clique(nome_personagem: String) -> void:
	if nome_personagem == alvo_atual:
		# Acertou o alvo
		pontos += 1
		atualizar_alvo()
	else:
		# Errou o alvo
		pontos -= 1
	# Atualiza a pontuação na UI
	label_pontos.text = "Pontos: " + str(pontos)
