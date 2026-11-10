extends Node2D
## ESCENA TEMPORAL de la prueba G1. No forma parte del juego: se excluye antes de la entrega.

const ACCIONES_J1: Array[String] = ["j1_arriba", "j1_abajo", "j1_izquierda", "j1_derecha", "j1_interactuar", "j1_procesar"]
const ACCIONES_J2: Array[String] = ["j2_arriba", "j2_abajo", "j2_izquierda", "j2_derecha", "j2_interactuar", "j2_procesar"]

@onready var _estado: Label = $Estado


func _process(_delta: float) -> void:
	_estado.text = "J1: %s\nJ2: %s" % [_pulsadas(ACCIONES_J1), _pulsadas(ACCIONES_J2)]


func _pulsadas(acciones: Array[String]) -> String:
	var lista := PackedStringArray()
	for accion in acciones:
		if Input.is_action_pressed(accion):
			lista.append(accion.substr(3))
	return ", ".join(lista)
