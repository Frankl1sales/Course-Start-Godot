extends Control

var ícone_fechar_normal: Resource = preload("res://assets/icons/close/close_normal.svg")
var ícone_fechar_pressed: Resource = preload("res://assets/icons/close/close_pressed.svg")

var ícone_música_normal: Resource = preload("res://assets/icons/music_note/music_note_normal.svg")
var ícone_música_pressionado: Resource = preload("res://assets/icons/music_note/music_note_pressed.svg")
var ícone_música_desligada_normal: Resource = preload("res://assets/icons/music_note/music_note_off_normal.svg")
var ícone_música_desligada_pressionado: Resource = preload("res://assets/icons/music_note/music_note_off_pressed.svg")

var ícone_sons_normal: Resource = preload("res://assets/icons/speaker/speaker_normal.svg")
var ícone_sons_pressionado: Resource = preload("res://assets/icons/speaker/speaker_pressed.svg")
var ícone_sons_mudo_normal: Resource = preload("res://assets/icons/speaker/speaker_mute_normal.svg")
var ícone_sons_mudo_pressionado: Resource = preload("res://assets/icons/speaker/speaker_mute_pressed.svg")

const TAMANHO_BASE_DA_FONTE: int = 32


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.música_desligada:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
	else:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
	
	$"Background/HSliderMúsica".set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Música"))) * 100)
	
	if GameManager.sons_mutados:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
	else:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal
	
	$Background/HSliderEfeitosSonoros.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100)
	
	$"Background/BotãoParâmetros".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_botão_fundo_fechar_pressed() -> void:
	visible = false


func _on_botão_fechar_button_down() -> void:
	$"Background/AspectRatioContainerBotãoFechar/BotãoFechar".icon = ícone_fechar_pressed


func _on_botão_fechar_button_up() -> void:
	$"Background/AspectRatioContainerBotãoFechar/BotãoFechar".icon = ícone_fechar_normal


func _on_botão_fechar_pressed() -> void:
	visible = false


func _on_botão_música_button_down() -> void:
	if GameManager.música_desligada:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_pressionado
	else:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_pressionado


func _on_botão_música_button_up() -> void:
	if GameManager.música_desligada:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
	else:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal


func _on_botão_música_pressed() -> void:
	var index_bus_música: int = AudioServer.get_bus_index("Música")
	
	GameManager.música_desligada = !GameManager.música_desligada
	
	if GameManager.música_desligada:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		get_parent().find_child("ContainerBotãoMúsica").find_child("BotãoMúsica").icon = ícone_música_desligada_normal
		AudioServer.set_bus_mute(index_bus_música, true)
	else:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		get_parent().find_child("ContainerBotãoMúsica").find_child("BotãoMúsica").icon = ícone_música_normal
		AudioServer.set_bus_mute(index_bus_música, false)


func _on_h_slider_música_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Música"), linear_to_db(value / 100.0))
	
	if value == 0:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		GameManager.música_desligada = true
		get_parent().find_child("ContainerBotãoMúsica").find_child("BotãoMúsica").icon = ícone_música_desligada_normal
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Música"), true)
	else:
		$"Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		GameManager.música_desligada = false
		get_parent().find_child("ContainerBotãoMúsica").find_child("BotãoMúsica").icon = ícone_música_normal
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Música"), false)


func _on_botão_efeitos_sonoros_button_down() -> void:
	if GameManager.sons_mutados:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_pressionado
	else:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_pressionado


func _on_botão_efeitos_sonoros_button_up() -> void:
	if GameManager.sons_mutados:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
	else:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal


func _on_botão_efeitos_sonoros_pressed() -> void:
	var index_bust_sons: int = AudioServer.get_bus_index("SFX")
	
	GameManager.sons_mutados = !GameManager.sons_mutados
	
	if GameManager.sons_mutados:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
		get_parent().find_child("ContainerBotãoSons").find_child("BotãoSons").icon = ícone_sons_mudo_normal
		AudioServer.set_bus_mute(index_bust_sons, true)
	else:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal
		get_parent().find_child("ContainerBotãoSons").find_child("BotãoSons").icon = ícone_sons_normal
		AudioServer.set_bus_mute(index_bust_sons, false)


func _on_h_slider_efeitos_sonoros_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))
	
	if value == 0:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
		get_parent().find_child("ContainerBotãoSons").find_child("BotãoSons").icon = ícone_sons_mudo_normal
		GameManager.sons_mutados = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	else:
		$"Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal
		get_parent().find_child("ContainerBotãoSons").find_child("BotãoSons").icon = ícone_sons_normal
		GameManager.sons_mutados = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)


func _on_botão_parâmetros_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/tela_pré_teste.tscn")
