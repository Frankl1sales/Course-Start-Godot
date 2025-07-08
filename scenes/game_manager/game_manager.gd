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

enum Velocidades {
	ESTÁTICA,
	LENTA,
	MÉDIA,
	RÁPIDA
}

@onready var escala: float = get_viewport_rect().size.x / 1152

# Parâmetros do sistema
var música_desligada: bool = false;
var sons_mutados: bool = false;

# Parâmetros do jogo
var velocidade: int = Velocidades.MÉDIA
var alvos_no_jogo: Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
var política_de_reposicionamento: int = PolíticasDeReposicionamento.TODOS
var alvo_atual: int = 0
var pontos_real: int = 0
var pontos_display: int = 0
var vidas: int = 10
var suporte: int = 0
var duração: float = 120.0
var mostrar_barra_de_tempo: bool = true
var animar: bool = true

# Variáveis para o log
var log_data: Array = []  # Armazena os dados do log
var id_sessão: String = ""  # ID único para a sessão
var data_sessão: String = ""  # Data da sessão
var tempo_resposta: float = 0.0
var timestamp_atual_sessão: float = 0.0  # Duração da sessão em segundos
var profissional_responsável: String = "Profissional Padrão"  # Nome do profissional responsável
var nome_jogo: String = "Toque Certo"  # Nome do jogo
var id_profissional: String = "ID_Padrão_Profissional"
var caminho: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/game_logs.csv"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Chamado a cada frame
func _process(delta: float) -> void:
	# Atualizar a duração da sessão
	timestamp_atual_sessão += delta
	tempo_resposta += delta

# Função para gerar um ID único para a sessão
func gerar_id_único() -> String:
	return str(randi()) + str(Time.get_ticks_msec())  # Combina um número aleatório com o tempo atual em milissegundos


# Função para obter a data e hora atuais
func obter_data_hora_atual() -> String:
	var data_hora: String = Time.get_datetime_string_from_system()  # Formato: "YYYY-MM-DDTHH:MM:SS"
	return data_hora


func iniciar_música() -> void:
	$"MúsicaDeFundo".play()


func parar_música() -> void:
	$"MúsicaDeFundo".stop()


func iniciar_jogo(número_de_alvos: int, tempo_de_duração: float, política_de_reposicionamento_do_jogo: int, velocidade_dos_alvos: int, id_prof: String = "", mostrar_tempo: bool = true, número_de_vidas: int = 2147483647, animar_ícones: bool = true) -> void:
	alvos_no_jogo = Alvos.values()
	alvos_no_jogo.shuffle()
	alvos_no_jogo = alvos_no_jogo.slice(0, número_de_alvos)
	
	duração = tempo_de_duração
	política_de_reposicionamento = política_de_reposicionamento_do_jogo
	velocidade = velocidade_dos_alvos
	alvo_atual = alvos_no_jogo.pick_random()
	id_profissional = id_prof
	mostrar_barra_de_tempo = mostrar_tempo
	vidas = número_de_vidas
	animar = animar_ícones

	pontos_real = 0
	pontos_display = 0
	suporte = 0
	timestamp_atual_sessão = 0.0
	tempo_resposta = 0.0
	log_data = []

	# Gerar ID único e data da sessão
	id_sessão = gerar_id_único()
	data_sessão = obter_data_hora_atual()
	print("ID da Sessão: ", id_sessão)
	print("Data da Sessão: ", data_sessão)
	
	get_tree().change_scene_to_file("res://scenes/jogo_principal/jogo_principal.tscn")


# Função de clique para verificar acerto
func clique(alvos: Array[int]) -> bool:
	# Se múltiplos alvos forem clicados em simultâneo devido à propagação do clique, o certo se sobrepõe aos errados
	if alvo_atual in alvos:
		pontos_real += 1
		pontos_display += 1
		
		var anterior: int = alvo_atual
		
		# O alvo novo sempre será diferente do anterior
		while alvo_atual == anterior and alvos_no_jogo.size() > 1:
			alvo_atual = alvos_no_jogo.pick_random()

		# Adiciona os dados ao log
		log_data.append([id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, tempo_resposta, pontos_real, alvo_atual, true, suporte, Velocidades.find_key(velocidade), vidas]) # Exemplo de log com acerto
		salvar_logs_csv()
		
		tempo_resposta = 0.0
		
		return true
	else:
		if pontos_display >= 1:
			pontos_display -= 1
		
		pontos_real -= 1
		
		if vidas != 2147483647:
			vidas -= 1
		
		log_data.append([id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, tempo_resposta, pontos_real, alvo_atual, false, suporte, Velocidades.find_key(velocidade), vidas])  # Exemplo de log com erro
		salvar_logs_csv()
		
		if vidas == 0:
			finalizar_sessão()
		
		return false


func mudança_no_suporte() -> void:
	# Adiciona uma linha indicando o novo suporte
	var file: FileAccess = FileAccess.open(caminho, FileAccess.READ_WRITE)
	
	file.seek_end()  # Vai para o final do arquivo
	file.store_line("%s,%s,%s,%f,%s,%s,%d,%d,%s,%s,%s,%d" % [id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, "MUDANÇA NO SUPORTE", pontos_real, alvo_atual, "N/A", suporte, Velocidades.find_key(velocidade), vidas])
	
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
		file.store_line("ID_Sessao,ID_Profissional,Data_Sessao,Duracao_Sessao,Nome_Jogo,Tempo_Resposta,Pontos,Alvo_Atual,Acerto,Suporte,Velocidade,Vidas")
		
		file.close()
	
	file = FileAccess.open(caminho, FileAccess.READ_WRITE)

	# Vai para o final do arquivo
	file.seek_end()

	# Armazena os logs
	for log_entry in log_data:
		file.store_line("%s,%s,%s,%f,%s,%f,%d,%s,%s,%s,%s,%d" % [
			log_entry[0], log_entry[1], log_entry[2], log_entry[3], log_entry[4],
			log_entry[5], log_entry[6], str(log_entry[7]), str(log_entry[8]), str(log_entry[9]),
			log_entry[10], log_entry[11]
		])
		
	if limpar:
		log_data = []

	file.close()
	print("✅ Logs salvos em: ", file.get_path_absolute())


# Função para finalizar a sessão e registrar o término
func finalizar_sessão(mudar_para_cena_final: bool = true) -> void:
	# Adiciona uma linha indicando o término da sessão
	var file: FileAccess = FileAccess.open(caminho, FileAccess.READ_WRITE)
	
	file.seek_end()  # Vai para o final do arquivo
	file.store_line("%s,%s,%s,%f,%s,%s,%d,%s,%s,%d,%s,%d" % [id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, "FIM DA SESSÃO", pontos_real, "N/A", "N/A", suporte, Velocidades.find_key(velocidade), vidas])
	
	file.close()
	print("✅ Término da sessão registrado no log.")
	
	if mudar_para_cena_final:
		get_tree().change_scene_to_file("res://UI/tela_final.tscn")


# Função para verificar se o arquivo foi salvo
func verificar_logs() -> void:
	if FileAccess.file_exists(caminho):
		print("📂 Arquivo encontrado!")
		
		var file: FileAccess = FileAccess.open(caminho, FileAccess.READ)
		while not file.eof_reached():
			print(file.get_line())  # Exibe cada linha do CSV no console
		file.close()
	else:
		print("❌ Arquivo NÃO encontrado!")


# Função para sair do jogo
func sair_do_jogo() -> void:
	print("Saindo do jogo...")  # Exibe uma mensagem de saída
	get_tree().quit()  # Encerra o jogo
