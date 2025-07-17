extends Control

signal barra_de_tempo_oculta(oculta: bool)
signal número_de_vidas_mudou(vidas: int)


var ícone_toggle_on: Resource = preload("res://assets/icons/toggle/toggle_on.svg")
var ícone_toggle_off: Resource = preload("res://assets/icons/toggle/toggle_off.svg")

var ícone_música_normal: Resource = preload("res://assets/icons/music_note/music_note_normal.svg")
var ícone_música_pressionado: Resource = preload("res://assets/icons/music_note/music_note_pressed.svg")
var ícone_música_desligada_normal: Resource = preload("res://assets/icons/music_note/music_note_off_normal.svg")
var ícone_música_desligada_pressionado: Resource = preload("res://assets/icons/music_note/music_note_off_pressed.svg")

var ícone_sons_normal: Resource = preload("res://assets/icons/speaker/speaker_normal.svg")
var ícone_sons_pressionado: Resource = preload("res://assets/icons/speaker/speaker_pressed.svg")
var ícone_sons_mudo_normal: Resource = preload("res://assets/icons/speaker/speaker_mute_normal.svg")
var ícone_sons_mudo_pressionado: Resource = preload("res://assets/icons/speaker/speaker_mute_pressed.svg")

const TAMANHO_BASE_DA_FONTE_LABEL_PAUSADO: int = 96
const TAMANHO_BASE_DA_FONTE: int = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_rect_size: Vector2 = get_viewport_rect().size
	var blur_amount: float
	
	if viewport_rect_size.x / 1152 > viewport_rect_size.y / 648:
		blur_amount = 1.5 * viewport_rect_size.y / 648
	else:
		blur_amount = 1.5 * viewport_rect_size.x / 1152
	
	$Blur.material.set_shader_parameter("amount", 1.5 * blur_amount)
	
	$LabelPausado.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE_LABEL_PAUSADO * GameManager.escala)
	
	$"BotãoVoltarAoJogo".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$LabelBarraDeTempo.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"LabelAnimações".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$LabelVidas.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$LineEditVidas.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"BotãoFinalizarSessão".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	
	$ToggleBarraDeTempo.icon = ícone_toggle_on if GameManager.mostrar_barra_de_tempo else ícone_toggle_off
	$ToggleBarraDeTempo.set_pressed_no_signal(GameManager.mostrar_barra_de_tempo)
	$"ToggleAnimações".icon = ícone_toggle_on if GameManager.animar else ícone_toggle_off
	$"ToggleAnimações".set_pressed_no_signal(GameManager.animar)
	
	$"HSliderMúsica".set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Música"))) * 100)
	$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal if GameManager.música_desligada else ícone_música_normal
	
	$"HSliderSons".set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100)
	$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal if GameManager.sons_mutados else ícone_sons_normal
	
	if GameManager.vidas != GameManager.INT_MAX:
		$LineEditVidas.text = str(GameManager.vidas)
	else:
		$LineEditVidas.text = "Ilimitadas"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_released("pausar"):
		get_viewport().set_input_as_handled()
		despausar()


func despausar():
	visible = false
	get_tree().paused = false


func _on_botão_voltar_ao_jogo_pressed() -> void:
	despausar()


func _on_toggle_barra_de_tempo_toggled(toggled_on: bool) -> void:
	GameManager.mostrar_barra_de_tempo = toggled_on
	barra_de_tempo_oculta.emit(not toggled_on)
	
	$ToggleBarraDeTempo.icon = ícone_toggle_on if toggled_on else ícone_toggle_off


func _on_toggle_animações_toggled(toggled_on: bool) -> void:
	GameManager.animar = toggled_on
	
	$"ToggleAnimações".icon = ícone_toggle_on if toggled_on else ícone_toggle_off


func _on_botão_música_button_down() -> void:
	if GameManager.música_desligada:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_pressionado
	else:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_pressionado


func _on_botão_música_button_up() -> void:
	if GameManager.música_desligada:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
	else:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal


func _on_botão_música_pressed() -> void:
	var index_bus_música: int = AudioServer.get_bus_index("Música")
	
	GameManager.música_desligada = !GameManager.música_desligada
	
	if GameManager.música_desligada:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		AudioServer.set_bus_mute(index_bus_música, true)
	else:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		AudioServer.set_bus_mute(index_bus_música, false)


func _on_h_slider_música_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Música"), linear_to_db(value / 100.0))
	
	if value == 0:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		GameManager.música_desligada = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Música"), true)
	else:
		$"AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		GameManager.música_desligada = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Música"), false)


func _on_botão_sons_button_down() -> void:
	if GameManager.sons_mutados:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_pressionado
	else:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_pressionado


func _on_botão_sons_button_up() -> void:
	if GameManager.sons_mutados:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal
	else:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_normal


func _on_botão_sons_pressed() -> void:
	var index_bust_sons: int = AudioServer.get_bus_index("SFX")
	
	GameManager.sons_mutados = !GameManager.sons_mutados
	
	if GameManager.sons_mutados:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal
		AudioServer.set_bus_mute(index_bust_sons, true)
	else:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_normal
		AudioServer.set_bus_mute(index_bust_sons, false)


func _on_h_slider_sons_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))
	
	if value == 0:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal
		GameManager.sons_mutados = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	else:
		$"AspectRatioContainerBotãoSons/BotãoSons".icon = ícone_sons_normal
		GameManager.sons_mutados = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)


func _on_line_edit_vidas_text_changed(new_text: String) -> void:
	var valor: int = int(new_text)
	
	if valor != 0:
		GameManager.vidas = valor
		número_de_vidas_mudou.emit(valor)
	else:
		GameManager.vidas = GameManager.INT_MAX
		número_de_vidas_mudou.emit(GameManager.INT_MAX)


func _on_line_edit_vidas_text_submitted(new_text: String) -> void:
	var valor: int = int(new_text)

	if valor <= 0:
		valor = GameManager.INT_MAX
	
	GameManager.vidas = valor
	número_de_vidas_mudou.emit(valor)

	if valor == GameManager.INT_MAX:
		$"LineEditVidas".text = "Ilimitadas"
	else:
		$"LineEditVidas".text = str(valor)


func _on_botão_finalizar_sessão_pressed() -> void:
	despausar()
	GameManager.finalizar_sessão()
