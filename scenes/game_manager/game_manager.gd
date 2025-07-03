extends Node2D


enum PolíticasDeReposicionamento {
	NENHUM,
	ALVO,
	TODOS
}


enum Alvos {
	DONUT,
	HAMBÚRGUER,
	PIZZA,
	OVO_FRITO,
	MAÇÃ,
	UVA,
	SORVETE,
	CUPCAKE,
	BRÓCOLIS,
	PICOLÉ
}

const VELOCIDADE_ZERO_PADRÃO: float = 0.0
const VELOCIDADE_LENTA_PADRÃO: float = 150.0
const VELOCIDADE_RÁPIDA_PADRÃO: float = 300.0
@onready var escala = get_viewport_rect().size.x / 1152

# Parâmetros do sistema
var música_desligada: bool = false;
var sons_mutados: bool = false;

# Parâmetros do jogo
var velocidade: float = -1.0
var alvos_no_jogo: Array = []
var política_de_reposicionamento: int
var alvo_atual: int
var pontos_real: int = 0
var pontos_display: int = 0
var suporte: int = 0
var duração: float = 120.0

# Variáveis para o log
var log_data: Array = []  # Armazena os dados do log
var id_sessão: String = ""  # ID único para a sessão
var data_sessão: String = ""  # Data da sessão
var duração_sessão: float = 0.0  # Duração da sessão em segundos
var profissional_responsável: String = "Profissional Padrão"  # Nome do profissional responsável
var nome_jogo: String = "Tapa Certo"  # Nome do jogo
var id_profissional: String = "ID_Padrão_Profissional"
var caminho = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/game_logs.csv"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Gerar ID único e data da sessão
	id_sessão = gerar_id_único()
	data_sessão = obter_data_hora_atual()
	print("ID da Sessão: ", id_sessão)
	print("Data da Sessão: ", data_sessão)

# Chamado a cada frame
func _process(delta: float) -> void:
	# Atualizar a duração da sessão
	duração_sessão += delta
	
var toque_contador = 0
var tempo_inicial = 0.0

func _input(event: InputEvent) -> void:
	# Finalizar o jogo com toque de quatro dedos três vezes em 5 segundos
	if event is InputEventScreenTouch and event.is_pressed():
		if event.index == 3:  # Verifica se há quatro dedos tocando
			if toque_contador == 0:
				tempo_inicial = Time.get_unix_time_from_system()  # Marca o tempo inicial
			toque_contador += 1
			
			if toque_contador == 3:  # Verifica se houve três toques
				var tempo_atual = Time.get_unix_time_from_system()
				if tempo_atual - tempo_inicial <= 5.0:
					get_tree().change_scene_to_file("res://UI/tela_final.tscn")
					toque_contador = 0  # Reinicia o contador
				else:
					toque_contador = 1  # Reinicia para o toque atual
					tempo_inicial = tempo_atual
	# Detectar se a tecla "ESC" foi pressionada para sair do jogo
	elif event.is_action_released("finalizar_sessão"):
		get_tree().change_scene_to_file("res://UI/tela_final.tscn")

# Função para gerar um ID único para a sessão
func gerar_id_único() -> String:
	return str(randi()) + str(Time.get_ticks_msec())  # Combina um número aleatório com o tempo atual em milissegundos

# Função para obter a data e hora atuais
func obter_data_hora_atual() -> String:
	var data_hora = Time.get_datetime_string_from_system()  # Formato: "YYYY-MM-DDTHH:MM:SS"
	return data_hora


func iniciar_música() -> void:
	$"MúsicaDeFundo".play()


func parar_música() -> void:
	$"MúsicaDeFundo".stop()


func iniciar_jogo(número_de_alvos: int, política_de_reposicionamento_do_jogo: int, velocidade_dos_alvos: float, id_prof: String = "") -> void:
	alvos_no_jogo = Alvos.values()
	alvos_no_jogo.shuffle()
	alvos_no_jogo = alvos_no_jogo.slice(0, número_de_alvos)
	
	política_de_reposicionamento = política_de_reposicionamento_do_jogo
	velocidade = velocidade_dos_alvos
	alvo_atual = alvos_no_jogo.pick_random()
	pontos_real = 0
	pontos_display = 0
	# Armazena os novos IDs
	id_profissional = id_prof
	
	get_tree().change_scene_to_file("res://scenes/jogo_principal/jogo_principal.tscn")



# Função de clique para verificar acerto
func clique(alvo: int) -> bool:
	var tempo_resposta = Time.get_ticks_msec() / 1000.0  # Tempo de resposta em segundos
	
	if alvo == alvo_atual:
		pontos_real += 1
		pontos_display += 1
		var anterior = alvo_atual
		
		# O alvo novo sempre será diferente do anterior
		while alvo_atual == anterior and alvos_no_jogo.size() > 1:
			alvo_atual = alvos_no_jogo.pick_random()

		# Adiciona os dados ao log
		log_data.append([id_sessão, id_profissional, data_sessão, duração_sessão, nome_jogo, tempo_resposta, pontos_real, alvo_atual, true, suporte]) # Exemplo de log com acerto
		salvar_logs_csv()
		
		return true
	else:
		if pontos_display >= 1:
			pontos_display -= 1
		
		pontos_real -= 1
		
		log_data.append([id_sessão, id_profissional, data_sessão, duração_sessão, nome_jogo, tempo_resposta, pontos_real, alvo_atual, false, suporte])  # Exemplo de log com erro
		salvar_logs_csv()
		
		return false
		
func mudança_no_suporte() -> void:
	# Adiciona uma linha indicando o novo suporte
	var file = FileAccess.open(caminho, FileAccess.READ_WRITE)
	
	file.seek_end()  # Vai para o final do arquivo
	file.store_line("%s,%s,%s,%f,%s,%s,%d,%s,%s,%s" % [id_sessão, id_profissional, data_sessão, duração_sessão, nome_jogo, "MUDANÇA NO SUPORTE", pontos_real, "N/A", "N/A", suporte])
	
	file.close()
	

# Função para salvar os logs em um arquivo CSV
func salvar_logs_csv(limpar: bool = true) -> void:
	var file: FileAccess
	
	if !FileAccess.file_exists(caminho):
		# Se o arquivo não existir, cria um novo e adiciona o cabeçalho
		file = FileAccess.open(caminho, FileAccess.WRITE)
		if file == null:
			print("❌ Erro ao criar o arquivo de log!")
			return
		
		# Escreve o cabeçalho apenas uma vez
		file.store_line("ID_Sessao,ID_Profissional,Data_Sessao,Duracao_Sessao,Nome_Jogo,Tempo_Resposta,Pontos,Alvo_Atual,Acerto,Suporte")
		
		file.close()
	
	file = FileAccess.open(caminho, FileAccess.READ_WRITE)

	# Vai para o final do arquivo
	file.seek_end()

	# Armazena os logs
	for log_entry in log_data:
		file.store_line("%s,%s,%s,%f,%s,%f,%d,%s,%s,%s" % [
			log_entry[0], log_entry[1], log_entry[2], log_entry[3], log_entry[4],
			log_entry[5], log_entry[6], str(log_entry[7]), str(log_entry[8]), str(log_entry[9])
		])
		
	if limpar:
		log_data = []

	file.close()
	print("✅ Logs salvos em: ", file.get_path_absolute())

# Função para finalizar a sessão e registrar o término
func finalizar_sessão() -> void:
	# Adiciona uma linha indicando o término da sessão
	var file = FileAccess.open(caminho, FileAccess.READ_WRITE)
	
	file.seek_end()  # Vai para o final do arquivo
	file.store_line("%s,%s,%s,%f,%s,%s,%d,%s,%s,%s" % [id_sessão, id_profissional, data_sessão, duração_sessão, nome_jogo, "FIM DA SESSÃO", pontos_real, "N/A", "N/A", "N/A"])
	
	file.close()
	print("✅ Término da sessão registrado no log.")

# Função para verificar se o arquivo foi salvo
func verificar_logs() -> void:
	if FileAccess.file_exists(caminho):
		print("📂 Arquivo encontrado!")
		
		var file = FileAccess.open(caminho, FileAccess.READ)
		while not file.eof_reached():
			print(file.get_line())  # Exibe cada linha do CSV no console
		file.close()
	else:
		print("❌ Arquivo NÃO encontrado!")

# Função para sair do jogo
func sair_do_jogo() -> void:
	print("Saindo do jogo...")  # Exibe uma mensagem de saída
	get_tree().quit()  # Encerra o jogo
