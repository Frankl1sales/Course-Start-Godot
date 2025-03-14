extends Node2D

# Variáveis
var alvo_atual: String = ""  # Nome do personagem-alvo ("Mago" ou "Cavalo")
var pontos: int = 0  # Pontuação do jogador

# Variáveis para log
var start_time: float = 0.0  # Tempo da última atualização do alvo
var total_cliques: int = 0
var log_data: Array = []  # Armazena os logs temporariamente


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
	alvo_atual = ["Mago", "Cavalo"].pick_random()
	
	# Atualiza a imagem do alvo
	if alvo_atual == "Mago":
		image_alvo.texture = textura_mago
	elif alvo_atual == "Cavalo":
		image_alvo.texture = textura_cavalo

	# Armazena o tempo de início para calcular o tempo de resposta
	start_time = Time.get_ticks_msec() / 1000.0  # Converte para segundos


# Detectar cliques nos personagens
func verificar_clique(nome_personagem: String) -> void:
	total_cliques += 1  # Contabiliza o clique do jogador
	
	var tempo_resposta = (Time.get_ticks_msec() / 1000.0) - start_time  # Calcula tempo de resposta
	
	var acerto = (nome_personagem == alvo_atual)  # Verifica se o clique foi correto
	if acerto:
		pontos += 1
	else:
		pontos -= 1

	# Atualiza a pontuação na UI
	label_pontos.text = "Pontos: " + str(pontos)

	# Salva o evento no log
	log_data.append([tempo_resposta, total_cliques, nome_personagem, alvo_atual, acerto])

	# Atualiza o alvo para a próxima rodada
	atualizar_alvo()

func salvar_logs_csv():
	var caminho = "C:/temp/wp-Godot/Course-YT/game_logs.csv"  # Caminho fixo
	var file = FileAccess.open(caminho, FileAccess.WRITE)
	
	file.store_line("Tempo_Resposta(s),Cliques,Personagem_Clicado,Alvo_Correto,Acerto")
	
	for log in log_data:
		file.store_line("%f,%d,%s,%s,%s" % [log[0], log[1], log[2], log[3], str(log[4])])
	
	file.close()
	print("✅ Logs salvos em: ", caminho)


func _exit_tree():
	salvar_logs_csv()
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()  # Fecha o jogo
