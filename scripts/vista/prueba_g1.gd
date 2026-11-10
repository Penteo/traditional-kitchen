extends Node2D
## ESCENA TEMPORAL de pruebas. No forma parte del juego: se excluye antes de la entrega.

const ACCIONES_J1: Array[String] = ["j1_arriba", "j1_abajo", "j1_izquierda", "j1_derecha", "j1_interactuar", "j1_procesar"]
const ACCIONES_J2: Array[String] = ["j2_arriba", "j2_abajo", "j2_izquierda", "j2_derecha", "j2_interactuar", "j2_procesar"]
const RUTAS_RECETAS: Array[String] = [
	"res://data/recetas/arepa_con_queso.tres",
	"res://data/recetas/empanadas.tres",
	"res://data/recetas/mute_santandereano.tres",
]

@onready var _estado: Label = $Estado
@onready var _chef1: Chef = $Chef1
@onready var _chef2: Chef = $Chef2
@onready var _controlador: ChefController = $ChefController

var _recetas: Array[Receta] = []


func _ready() -> void:
	for ruta in RUTAS_RECETAS:
		_recetas.append(load(ruta) as Receta)
	var escena := load("res://scenes/entities/estaciones/dispensador_platos.tscn") as PackedScene
	var dispensador := escena.instantiate() as DispensadorPlatos
	dispensador.position = Vector2(1480, 200)
	dispensador.recetas = _recetas
	add_child(dispensador)
	_controlador.ciclo_terminado.connect(_avanzar_estaciones)


func _process(_delta: float) -> void:
	_estado.text = "J1: %s%s\nJ2: %s%s\nT = forzar interaccion simultanea (prueba R3)" % [_pulsadas(ACCIONES_J1), _plato_de(_chef1), _pulsadas(ACCIONES_J2), _plato_de(_chef2)]


## Sustituye al reloj de la partida (Lote 2): avanza las estaciones despues de las acciones de J1 y J2.
func _avanzar_estaciones(delta: float) -> void:
	get_tree().call_group("estaciones_temporizadas", "actualizar", delta)


func _unhandled_input(evento: InputEvent) -> void:
	var tecla := evento as InputEventKey
	if tecla != null and tecla.pressed and not tecla.echo and tecla.keycode == KEY_T:
		var pedidos: Array[Dictionary] = [
			{"chef": _chef1, "accion": ChefController.Accion.INTERACTUAR},
			{"chef": _chef2, "accion": ChefController.Accion.INTERACTUAR},
		]
		_controlador.resolver_acciones(pedidos)


func _plato_de(chef: Chef) -> String:
	var plato := chef.item_en_mano as Plato
	if plato == null:
		return ""
	for receta in _recetas:
		if plato.coincide(receta):
			return "  | PLATO COMPLETO: " + receta.nombre
	return "  | plato incompleto"


func _pulsadas(acciones: Array[String]) -> String:
	var lista := PackedStringArray()
	for accion in acciones:
		if Input.is_action_pressed(accion):
			lista.append(accion.substr(3))
	return ", ".join(lista)
