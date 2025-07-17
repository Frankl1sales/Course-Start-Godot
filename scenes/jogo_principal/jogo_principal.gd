extends Node2D


const ícone_pausa_normal: Resource = preload("res://assets/icons/pause/pause_normal.svg")
const ícone_pausa_pressed: Resource = preload("res://assets/icons/pause/pause_pressed.svg")

@onready var donut: Area2D = $Donut
@onready var hambúrguer: Area2D = $"Hambúrguer"
@onready var pizza: Area2D = $Pizza
@onready var ovo_frito: Area2D = $OvoFrito
@onready var maçã: Area2D = $"Maçã"
@onready var uva: Area2D = $Uva
@onready var sorvete: Area2D = $Sorvete
@onready var cupcake: Area2D = $Cupcake
@onready var brócolis: Area2D = $"Brócolis"
@onready var picolé: Area2D = $"Picolé"

@onready var current_target_box_hollow_default: Resource = preload("res://assets/current_target_box_hollow.png")
@onready var current_target_box_hollow_red: Resource = preload("res://assets/current_target_box_hollow_red.png")

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var velocidade: float
var alvos_no_jogo: Array[Area2D] = []
var vetores_de_movimento_dos_alvos: Array[Vector2] = []
var sprites_dos_alvos: Array[Sprite2D] = []
var sprite_do_alvo_atual: Sprite2D
var tamanho_da_janela: Vector2
var tempo_total: float = 0.0
var tempo_desde_toque_certo: float = 0.0

var toques: Array[int] = [];

var tamanho_célula: Vector2
var offset_máximo: Vector2
const BASE_OFFSET_MÁXIMO: int = 50

var distância_mínima_entre_alvos: float = 125.0

var grid_de_alvos: Array[Array] = []

const TAMANHO_BASE_DA_FONTE: int = 64
const TEMPO_ATÉ_AUMENTAR_O_SUPORTE: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:   
	tamanho_da_janela = get_viewport_rect().size
	
	distância_mínima_entre_alvos *= GameManager.escala

	match GameManager.velocidade:
		GameManager.Velocidades.ESTÁTICA:
			velocidade = 0.0
		GameManager.Velocidades.LENTA:
			velocidade = 50.0 * GameManager.escala
		GameManager.Velocidades.MÉDIA:
			velocidade = 150.0 * GameManager.escala
		GameManager.Velocidades.RÁPIDA:
			velocidade = 300.0 * GameManager.escala
		_:
			assert(false, "Velocidade inválida")
		
	atualizar_placar()
	atualizar_vidas()

	# Inicialização do ruído azul
	tamanho_célula.x = tamanho_da_janela.x / GameManager.colunas
	tamanho_célula.y = tamanho_da_janela.y / GameManager.linhas
	
	grid_de_alvos.resize(GameManager.colunas)
	
	var array_temporário: Array[int]
	array_temporário.resize(GameManager.linhas)
	array_temporário.fill(-1)
	
	for i: int in grid_de_alvos.size():
		grid_de_alvos[i] = array_temporário.duplicate()
	
	# A primeira célula é reservada para o indicador do alvo atual
	grid_de_alvos[0][0] = GameManager.INT_MAX
	
	var aspect_ratio_célula: float = tamanho_célula.y / tamanho_célula.x
	offset_máximo = Vector2(BASE_OFFSET_MÁXIMO * GameManager.escala, BASE_OFFSET_MÁXIMO * GameManager.escala * aspect_ratio_célula)
	

	# Inicialização dos alvos
	for alvo: int in GameManager.alvos_no_jogo:
		match alvo:
			GameManager.Alvos.DONUT:
				alvos_no_jogo.append(donut)
			GameManager.Alvos.HAMBÚRGUER:
				alvos_no_jogo.append(hambúrguer)
			GameManager.Alvos.PIZZA:
				alvos_no_jogo.append(pizza)
			GameManager.Alvos.OVO_FRITO:
				alvos_no_jogo.append(ovo_frito)
			GameManager.Alvos.MAÇÃ:
				alvos_no_jogo.append(maçã)
			GameManager.Alvos.UVA:
				alvos_no_jogo.append(uva)
			GameManager.Alvos.SORVETE:
				alvos_no_jogo.append(sorvete)
			GameManager.Alvos.CUPCAKE:
				alvos_no_jogo.append(cupcake)
			GameManager.Alvos.BRÓCOLIS:
				alvos_no_jogo.append(brócolis)
			GameManager.Alvos.PICOLÉ:
				alvos_no_jogo.append(picolé)
			_:
				assert(false, "Alvo inválido")
				
	vetores_de_movimento_dos_alvos.resize(alvos_no_jogo.size())
	sprites_dos_alvos.resize(alvos_no_jogo.size())
	
	for alvo: Area2D in alvos_no_jogo:
		alvo.tocado.connect(func(tipo: int):
			toques.append(tipo)
		)
	
	for i: int in alvos_no_jogo.size():
		alvos_no_jogo[i].scale = Vector2(GameManager.escala, GameManager.escala)
		
		for child: Node in alvos_no_jogo[i].get_children():
			if child is Sprite2D:
				sprites_dos_alvos[i] = child.duplicate()
				
				sprites_dos_alvos[i].scale *= GameManager.escala
				sprites_dos_alvos[i].position = Vector2(75 * GameManager.escala, 75 * GameManager.escala)
				
		vetores_de_movimento_dos_alvos[i] = vetor_de_movimento_aleatório()

	spawnar_todos_os_alvos()
	
	# Não mantenha as células ocupadas se os alvos vão se mover
	if GameManager.velocidade == GameManager.Velocidades.ESTÁTICA:
		remover_todos_os_alvos_do_grid()
	
	
	# Inicialização dos indicadores da interface
	setar_sprite_alvo(GameManager.alvos_no_jogo.find(GameManager.alvo_atual))
	$CanvasLayer/ControlAlvo/RectAlvo.scale = Vector2(GameManager.escala, GameManager.escala)
	
	$CanvasLayer/AjudaAlvo.texture = current_target_box_hollow_default
	
	$CanvasLayer/AjudaAlvo.scale = Vector2(GameManager.escala, GameManager.escala)
	
	$BarraDeTempo.scale = Vector2(0, GameManager.escala)
	$BarraDeTempo.global_position = Vector2(0.0, tamanho_da_janela.y - 16 * GameManager.escala)
	$BarraDeTempo.visible = GameManager.mostrar_barra_de_tempo
	
	$CanvasLayer/LabelPontos.add_theme_font_size_override("font_size", GameManager.escala * TAMANHO_BASE_DA_FONTE)
	$CanvasLayer/LabelVidas.add_theme_font_size_override("font_size", GameManager.escala * TAMANHO_BASE_DA_FONTE)

	if GameManager.vidas == GameManager.INT_MAX:
		$CanvasLayer/LabelVidas.visible = false
		$CanvasLayer/Heart.visible = false
		$CanvasLayer/HeartAnimation.visible = false
		
	$CanvasLayer/Heart.global_position *= GameManager.escala
	$CanvasLayer/HeartAnimation.global_position *= GameManager.escala
	$CanvasLayer/Star.global_position *= GameManager.escala
	
	$CanvasLayer/Heart.scale *= GameManager.escala
	$CanvasLayer/HeartAnimation.scale *= GameManager.escala
	$CanvasLayer/Star.scale *= GameManager.escala

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tempo_total += delta
	tempo_desde_toque_certo += delta
	
	if tempo_total >= GameManager.duração:
		GameManager.finalizar_sessão()
		
	if GameManager.duração != INF:
		var progresso: float = tempo_total / GameManager.duração
		
		$BarraDeTempo.scale = Vector2(progresso * tamanho_da_janela.x / 32, GameManager.escala)
		$BarraDeTempo.global_position.x = progresso * tamanho_da_janela.x / 2

	# Tratamento dos toque, se múltiplos alvos forem clicados em simultâneo devido à propagação do toque o certo se sobrepõe aos errados
	if toques.size() != 0:
		var alvo_original: int = GameManager.alvos_no_jogo.find(GameManager.alvo_atual)
		var certo: bool = GameManager.toque(toques)
		
		if certo:
			$TapRight.play()
			
			if GameManager.animar:
				$CanvasLayer/Star.play()
			
			alterar_suporte(0)
			tempo_desde_toque_certo = 0.0
			
			$CanvasLayer/AjudaAlvo.global_position = Vector2(0, -150 * GameManager.escala)
			
			var index: int = GameManager.alvos_no_jogo.find(GameManager.alvo_atual)
			setar_sprite_alvo(index)
			
			if GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.ALVO:
				# Reposiciona o alvo imóvel
				if GameManager.velocidade == GameManager.Velocidades.ESTÁTICA:
					trocar_alvo_de_posição(alvo_original)
				# Reposiciona o alvo móvel
				else:
					vetores_de_movimento_dos_alvos[alvo_original] = vetor_de_movimento_aleatório()
					
					var posição_original: Vector2 = centro_de_alvo(alvo_original)
					
					var tentativas: int = 0

					while true:                
						alvos_no_jogo[alvo_original].global_position = Vector2(rng.randf_range(0, tamanho_da_janela.x - alvos_no_jogo[alvo_original].width * GameManager.escala),
																			rng.randf_range(0, tamanho_da_janela.y - alvos_no_jogo[alvo_original].height * GameManager.escala))
						
						var colisão: bool = false
						var colisão_com_o_indicador_do_alvo: bool = false
						
						for i: int in alvos_no_jogo.size():
							if i == alvo_original:
								continue
							
							if distância_entre_alvos(i, alvo_original) < distância_mínima_entre_alvos:
								colisão = true
								break
						
						# Detecta se o alvo está na área do indicador do alvo
						if distância_entre_alvos(alvo_original, -1, Vector2(0, 0)) < 200 * GameManager.escala:
							colisão = true
							colisão_com_o_indicador_do_alvo = true
							
						# Detecta se o alvo está muito perto da posição inicial
						if distância_entre_alvos(alvo_original, -1, posição_original) < 300 * GameManager.escala:
							colisão = true
								
						if not colisão or (tentativas >= 100 and not colisão_com_o_indicador_do_alvo):
							break
			elif GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.TODOS:
				spawnar_todos_os_alvos()
				
		else:
			if GameManager.vidas != 0:
				$TapWrong.play()
				
				if GameManager.animar and GameManager.vidas != GameManager.INT_MAX:
					$CanvasLayer/HeartAnimation.play()
				
				if GameManager.vidas != GameManager.INT_MAX:
					$CanvasLayer/MenuPausa/LineEditVidas.text = str(GameManager.vidas)
			
		atualizar_placar()
		atualizar_vidas()
		
		toques.clear()
	
	var novo_suporte: int = min(3, floor(tempo_desde_toque_certo / TEMPO_ATÉ_AUMENTAR_O_SUPORTE))
	
	if novo_suporte != GameManager.suporte:
		alterar_suporte(novo_suporte)
	
	for i: int in alvos_no_jogo.size():
		alvos_no_jogo[i].global_position += vetores_de_movimento_dos_alvos[i] * delta
		
		if vetores_de_movimento_dos_alvos[i].x < 0 and alvos_no_jogo[i].global_position.x < 0:
			vetores_de_movimento_dos_alvos[i].x *= -1
		
		if vetores_de_movimento_dos_alvos[i].x > 0 and alvos_no_jogo[i].global_position.x + alvos_no_jogo[i].width * GameManager.escala > tamanho_da_janela.x:
			vetores_de_movimento_dos_alvos[i].x *= -1

		if vetores_de_movimento_dos_alvos[i].y < 0 and alvos_no_jogo[i].global_position.y < 0:
			vetores_de_movimento_dos_alvos[i].y *= -1

		if vetores_de_movimento_dos_alvos[i].y > 0 and alvos_no_jogo[i].global_position.y + alvos_no_jogo[i].height * GameManager.escala > tamanho_da_janela.y:
			vetores_de_movimento_dos_alvos[i].y *= -1

	if (GameManager.suporte > 0):
		var alvo_atual: Area2D = alvos_no_jogo[GameManager.alvos_no_jogo.find(GameManager.alvo_atual)]
		
		var escala_ajuda_alvo: float = abs(sin(tempo_total * GameManager.suporte) * (GameManager.suporte - 1) * 0.1)
		$CanvasLayer/AjudaAlvo.scale = Vector2(GameManager.escala + GameManager.escala * escala_ajuda_alvo, GameManager.escala + GameManager.escala * escala_ajuda_alvo)
		
		$CanvasLayer/AjudaAlvo.global_position = Vector2(alvo_atual.global_position.x + (alvo_atual.width / 2 - 75 * (1 + escala_ajuda_alvo)) * GameManager.escala,
														 alvo_atual.global_position.y + (alvo_atual.height / 2 - 75 * (1 + escala_ajuda_alvo)) * GameManager.escala)
	else:
		$CanvasLayer/AjudaAlvo.scale = Vector2(0, 0)
		$CanvasLayer/AjudaAlvo.global_position = Vector2(-10000, -10000)


func _input(event: InputEvent) -> void:
	if event.is_action_released("pausar"):
		$CanvasLayer/MenuPausa.visible = true
		get_tree().paused = true


func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pausar()


func alterar_suporte(novo_suporte: int) -> void:
	if (novo_suporte != GameManager.suporte):
		GameManager.suporte = novo_suporte
		GameManager.mudança_no_suporte()
		
		if novo_suporte == 3:
			$CanvasLayer/AjudaAlvo.texture = current_target_box_hollow_red
		else:
			$CanvasLayer/AjudaAlvo.texture = current_target_box_hollow_default

func setar_sprite_alvo(index: int) -> void:
	if sprite_do_alvo_atual != null:
		$CanvasLayer/ControlAlvo.remove_child(sprite_do_alvo_atual)
	
	$CanvasLayer/ControlAlvo.add_child(sprites_dos_alvos[index])
	sprite_do_alvo_atual = sprites_dos_alvos[index]


func atualizar_placar() -> void:
	$CanvasLayer/LabelPontos.text = str(GameManager.pontos_display)
	

func atualizar_vidas() -> void:
	if GameManager.vidas != GameManager.INT_MAX:
		$CanvasLayer/LabelVidas.text = str(GameManager.vidas)
 

func vetor_de_movimento_aleatório() -> Vector2:
	var vetor_de_movimento: Vector2 = Vector2(rng.randi_range(0, 1), rng.randi_range(0, 1))
		
	if vetor_de_movimento.x == 0:
		vetor_de_movimento.x = -1.0
	
	if vetor_de_movimento.y == 0:
		vetor_de_movimento.y = -1.0
		
	vetor_de_movimento = vetor_de_movimento.normalized() * velocidade
		
	return vetor_de_movimento
   
	
func spawnar_alvo(alvo: int, ocupar: bool) -> void:
	var coluna: int
	var linha: int
	
	# Cria uma lista de células não ocupadas
	var células_vazias: Array[Array] = []
	for i: int in GameManager.colunas:
		for j: int in GameManager.linhas:
			if grid_de_alvos[i][j] < 0:
				células_vazias.append([i, j])
	
	# Escolhe uma célula aleatória da lista
	if células_vazias.size() > 0:
		var célula_escolhida: Array = células_vazias[rng.randi_range(0, células_vazias.size() - 1)]
		coluna = célula_escolhida[0]
		linha = célula_escolhida[1]
	else:
		# Caso não haja células vazias, escolhe uma célula aleatória
		coluna = rng.randi_range(0, GameManager.colunas - 1)
		linha = rng.randi_range(0, GameManager.linhas - 1)
	
	if ocupar:
		grid_de_alvos[coluna][linha] = alvo
		
	var pos_x: float = coluna * tamanho_célula.x + tamanho_célula.x / 2 + rng.randf_range(-offset_máximo.x, offset_máximo.x)
	var pos_y: float = linha * tamanho_célula.y + tamanho_célula.y / 2 + rng.randf_range(-offset_máximo.y, offset_máximo.y)
	
	alvos_no_jogo[alvo].global_position = Vector2(pos_x - alvos_no_jogo[alvo].width * GameManager.escala / 2,\
												  pos_y - alvos_no_jogo[alvo].height * GameManager.escala / 2)


func spawnar_todos_os_alvos() -> void:
	remover_todos_os_alvos_do_grid()
	
	for i: int in alvos_no_jogo.size():
		spawnar_alvo(i, true)


func remover_alvo_do_grid(alvo: int) -> bool:
	for i: int in grid_de_alvos.size():
		for j: int in grid_de_alvos[i].size():
			if grid_de_alvos[i][j] == alvo:
				grid_de_alvos[i][j] = -1
				return true
	
	return false


func encontrar_posição_de_alvo_no_grid(alvo: int) -> Array[int]:
	for i: int in grid_de_alvos.size():
		for j: int in grid_de_alvos[i].size():
			if grid_de_alvos[i][j] == alvo:
				return [i, j]
	
	return [-1, -1]


func trocar_alvo_de_posição(alvo: int) -> void:
	var posição_atual: Array[int] = encontrar_posição_de_alvo_no_grid(alvo)

	assert(posição_atual[0] >= 0 and posição_atual[1] >= 0, "Alvo não encontrado no grid")

	spawnar_alvo(alvo, true)
	grid_de_alvos[posição_atual[0]][posição_atual[1]] = -1
		

func remover_todos_os_alvos_do_grid() -> void:
	for i: int in grid_de_alvos.size():
		for j: int in grid_de_alvos[i].size():
			grid_de_alvos[i][j] = -1

	grid_de_alvos[0][0] = GameManager.INT_MAX


func centro_de_alvo(alvo: int) -> Vector2:
	return alvos_no_jogo[alvo].global_position + Vector2(alvos_no_jogo[alvo].width / 2 * GameManager.escala,
														 alvos_no_jogo[alvo].height / 2 * GameManager.escala)


# Calcula a distância entre o centro de dois alvos. Use -1 em um dos alvos para especificar um ponto
# arbitrário no terceiro argumento ou -1 nos dois alvos para especificar dois pontos arbitrários no
# terceiro e quarto argumento e calcular a distância entre eles.
func distância_entre_alvos(a: int, b: int, pos_1: Vector2 = Vector2(0, 0), pos_2: Vector2 = Vector2(0, 0)) -> float:
	var centro_a: Vector2
	var centro_b: Vector2
	
	if a == -1 and b == -1:
		centro_a = pos_1
		centro_b = pos_2
	elif a == -1:
		centro_a = pos_1
		centro_b = centro_de_alvo(b)
	elif b == -1:
		centro_a = centro_de_alvo(a)
		centro_b = pos_1
	else:
		centro_a = centro_de_alvo(a)
		centro_b = centro_de_alvo(b)
	
	return sqrt(pow(centro_a.x - centro_b.x, 2) + pow(centro_a.y - centro_b.y, 2))


func pausar():
	$CanvasLayer/MenuPausa.visible = true
	get_tree().paused = true


func _on_botão_pausa_button_down() -> void:
	$"CanvasLayer/ContainerBotãoPausa/BotãoPausa".icon = ícone_pausa_pressed


func _on_botão_pausa_button_up() -> void:
	$"CanvasLayer/ContainerBotãoPausa/BotãoPausa".icon = ícone_pausa_normal


func _on_botão_pausa_pressed() -> void:
	pausar()


func _on_menu_pausa_barra_de_tempo_oculta(oculta: bool) -> void:
	$BarraDeTempo.visible = not oculta


func _on_menu_pausa_número_de_vidas_mudou(vidas: int) -> void:
	if vidas == GameManager.INT_MAX:
		$CanvasLayer/LabelVidas.visible = false
		$CanvasLayer/Heart.visible = false
		$CanvasLayer/HeartAnimation.visible = false
	else:
		$CanvasLayer/LabelVidas.visible = true
		$CanvasLayer/Heart.visible = true
		$CanvasLayer/HeartAnimation.visible = true
		$CanvasLayer/LabelVidas.text = str(vidas)
		
