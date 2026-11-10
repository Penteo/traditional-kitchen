extends Node2D
## ESCENA TEMPORAL de pruebas. No forma parte del juego: se excluye antes de la entrega.

const ACCIONES_J1: Array[String] = ["j1_arriba", "j1_abajo", "j1_izquierda", "j1_derecha", "j1_interactuar", "j1_procesar"]
const ACCIONES_J2: Array[String] = ["j2_arriba", "j2_abajo", "j2_izquierda", "j2_derecha", "j2_interactuar", "j2_procesar"]

@onready var _estado: Label = $Estado
@onready var _chef1: Chef = $Chef1
@onready var _chef2: Chef = $Chef2
@onready var _controlador: ChefController = $ChefController


func _process(_delta: float) -> void:
	_estado.text = "J1: %s\nJ2: %s\nT = forzar interaccion simultanea (prueba R3)" % [_pulsadas(ACCIONES_J1), _pulsadas(ACCIONES_J2)]


func _unhandled_input(evento: InputEvent) -> void:
	var tecla := evento as InputEventKey
	if tecla != null and tecla.pressed and not tecla.echo and tecla.keycode == KEY_T:
		var actuan: Array[Chef] = [_chef1, _chef2]
		_controlador.resolver_interacciones(actuan)


func _pulsadas(acciones: Array[String]) -> String:
	var lista := PackedStringArray()
	for accion in acciones:
		if Input.is_action_pressed(accion):
			lista.append(accion.substr(3))
	return ", ".join(lista)
