extends CharacterBody2D

var velocidade_mago: float = 400.0
var direcao_move: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_mago()
	
func move_mago() -> void:
	# Movimento horizontal
	if Input.is_action_pressed("mv_direito"):
		direcao_move.x = 1
	elif Input.is_action_pressed("mv_esquerdo"):
		direcao_move.x = -1
	else:
		direcao_move.x = 0
	# Movimento Vertical
	if Input.is_action_pressed("mv_cima"):
		direcao_move.y = -1
	elif Input.is_action_pressed("mv_baixo"):
		direcao_move.y = 1
	else:
		direcao_move.y = 0
		
	# aplica as mudançasna direção do jogador
	velocity = direcao_move.normalized() * velocidade_mago
	move_and_slide()
	
		
