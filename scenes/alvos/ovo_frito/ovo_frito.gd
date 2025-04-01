extends Area2D


const width: float = 115.75
const height: float = 114.0
const tipo: int = GameManager.Alvos.OVO_FRITO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_parent().clique(tipo)
