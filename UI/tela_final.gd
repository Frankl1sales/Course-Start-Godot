extends Control


const TAMANHO_BASE_DA_FONTE_LABEL_PARABÉNS: int = 96
const TAMANHO_BASE_DA_FONTE_BOTÕES: int = 55

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"LabelParabéns".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE_LABEL_PARABÉNS * GameManager.escala)
	$"ContainerBotões/BotãoMenuPrincipal".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE_BOTÕES * GameManager.escala)
	$"ContainerBotões/BotãoSair".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE_BOTÕES * GameManager.escala)
	
	$"LabelParabéns".text = "Parabéns você obteve " + str(GameManager.pontos_display) + " ponto" + \
	("s!" if GameManager.pontos_display != 1 else "!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_botão_sair_pressed() -> void:
	GameManager.sair_do_jogo()


func _on_botão_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/tela_inicial_teste.tscn")
