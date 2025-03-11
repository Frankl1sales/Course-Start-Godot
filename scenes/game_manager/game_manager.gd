extends Node

enum Dificuldades {
	MUITO_FÁCIL, # Alvos não se movimentam e não trocam de posição quando tocados adequadamente.
	FÁCIL, # Alvos não se movimentam, trocam de posição quando tocados adequadamente.
	MÉDIO, # Alvos se movimentam lentamente por padrão, não trocam de posição quando tocados adequadamente.
	MÉDIO_DIFÍCIL, # Alvos se movimentam lentamente por padrão, trocam de posição quando tocados adequadamente.
	DIFÍCIL, # Alvos se movimentam rapidamente por padrão, não trocam de posição quando tocados adequadamente.
	MUITO_DIFÍCIL, # Alvos se movimentam rapidamente por padrão, trocam de posição quando tocados adequadamente.
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


const VELOCIDADE_LENTA_PADRÃO: float = 150
const VELOCIDADE_RÁPIDA_PADRÃO: float = 300

# Parâmetros do sistema
var música_desligada: bool = false;
var sons_mutados: bool = false;

# Parâmetros do jogo
var dificuldade
var override_velocidade: float = -1.0
var alvos_no_jogo: Array = []


var alvo_atual: int
var pontos = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func iniciar_múscia() -> void:
	$"MúsicaDeFundo".play()


func parar_música() -> void:
	$"MúsicaDeFundo".stop()


func iniciar_jogo(dificuldade_do_jogo: int, número_de_alvos: int, override_velocidade_dos_alvos: int = -1) -> void:
	alvos_no_jogo = Alvos.values()
	alvos_no_jogo.shuffle()
	alvos_no_jogo = alvos_no_jogo.slice(0, número_de_alvos)
	
	dificuldade = dificuldade_do_jogo
	override_velocidade = override_velocidade_dos_alvos
	
	alvo_atual = alvos_no_jogo.pick_random()
	pontos = 0
	
	get_tree().change_scene_to_file("res://scenes/jogo_principal/jogo_principal.tscn")


func clique(alvo: int) ->  bool:	
	if alvo == alvo_atual:
		GameManager.pontos += 1
		
		var anterior = alvo_atual
		
		# O alvo novo sempre será diferente do anterior
		while alvo_atual == anterior and alvos_no_jogo.size() > 1:
			alvo_atual = alvos_no_jogo.pick_random()
		
		return true
	else:
		GameManager.pontos -= 1
		return false
