extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"LabelParabéns".text = "Parabéns você obteve " + str(GameManager.pontos_display) + " ponto" + \
	("s!" if GameManager.pontos_display != 1 else "!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_botão_sair_pressed() -> void:
	GameManager.sair_do_jogo()


func _on_botão_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/tela_inicial_teste.tscn")
