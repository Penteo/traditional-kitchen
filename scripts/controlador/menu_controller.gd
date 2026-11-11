class_name MenuController
extends Node
## Navegacion entre pantallas. Las pantallas piden ir a otra con senales; este controlador decide.

const PANTALLAS: Dictionary = {
	"menu_principal": "res://scenes/ui/menu_principal.tscn",
	"seleccion_nivel": "res://scenes/ui/seleccion_nivel.tscn",
	"ficha_receta": "res://scenes/ui/ficha_receta.tscn",
	"como_jugar": "res://scenes/ui/como_jugar.tscn",
	"codice": "res://scenes/ui/codice.tscn",
	"opciones": "res://scenes/ui/opciones.tscn",
	"creditos": "res://scenes/ui/creditos.tscn",
	"escena_cocina": "res://scenes/game/escena_cocina.tscn",
}
const PANTALLAS_DE_MENU: Array[String] = [
	"menu_principal", "seleccion_nivel", "ficha_receta", "como_jugar", "codice", "opciones", "creditos",
]

var nivel_seleccionado: int = 1
var nombre_actual: String = ""
var pantalla_actual: Node = null

var _historial: Array[String] = []


func _ready() -> void:
	navegar("menu_principal")


## Va a una pantalla. Si ya estaba en el historial, regresa a ella. registrar_actual=false reemplaza la actual.
func navegar(nombre: String, datos: Dictionary = {}, registrar_actual: bool = true) -> void:
	if not PANTALLAS.has(nombre):
		push_warning("Pantalla desconocida: " + nombre)
		return
	var indice := _historial.find(nombre)
	if indice >= 0:
		_historial.resize(indice)
	elif registrar_actual and nombre_actual != "" and nombre_actual != nombre:
		_historial.append(nombre_actual)
	_mostrar(nombre, datos)


func volver() -> void:
	if _historial.is_empty():
		return
	var anterior: String = _historial.pop_back()
	_mostrar(anterior, {})


func seleccionar_nivel(numero: int) -> void:
	if not GameController.nivel_esta_desbloqueado(numero):
		return
	nivel_seleccionado = numero
	navegar("ficha_receta", {"nivel": Nivel.cargar(numero)})


func salir() -> void:
	get_tree().quit()


func _mostrar(nombre: String, datos: Dictionary) -> void:
	if pantalla_actual != null:
		pantalla_actual.queue_free()
	var nueva := (load(PANTALLAS[nombre]) as PackedScene).instantiate()
	if nueva.has_method("preparar"):
		nueva.call("preparar", datos)
	_conectar(nueva)
	add_child(nueva)
	pantalla_actual = nueva
	nombre_actual = nombre
	if PANTALLAS_DE_MENU.has(nombre):
		AudioController.reproducir_pista("menu")


func _conectar(nueva: Node) -> void:
	var pantalla := nueva as Pantalla
	if pantalla != null:
		pantalla.volver_solicitado.connect(volver)
	var menu := nueva as MenuPrincipalView
	if menu != null:
		menu.jugar_solicitado.connect(navegar.bind("seleccion_nivel"))
		menu.como_jugar_solicitado.connect(navegar.bind("como_jugar"))
		menu.codice_solicitado.connect(navegar.bind("codice"))
		menu.opciones_solicitado.connect(navegar.bind("opciones"))
		menu.creditos_solicitado.connect(navegar.bind("creditos"))
		menu.salir_solicitado.connect(salir)
	var seleccion := nueva as SeleccionNivelView
	if seleccion != null:
		seleccion.nivel_elegido.connect(seleccionar_nivel)
	var ficha := nueva as FichaRecetaView
	if ficha != null:
		ficha.ficha_terminada.connect(_iniciar_partida)
	var cocina := nueva as EscenaCocinaView
	if cocina != null:
		cocina.salir_solicitado.connect(navegar.bind("menu_principal"))
		cocina.continuar_solicitado.connect(navegar.bind("seleccion_nivel"))


## La ficha termina (5 s o se omite) y empieza la partida; la ficha no queda en el historial.
func _iniciar_partida() -> void:
	navegar("escena_cocina", {"nivel": Nivel.cargar(nivel_seleccionado)}, false)


## Esc vuelve a la pantalla anterior, salvo en el menu principal y en la partida (alli Esc es la pausa).
func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel") and nombre_actual != "menu_principal" and nombre_actual != "escena_cocina":
		volver()
