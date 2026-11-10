extends Node
## Coordina la partida: crea la sesion y la hace avanzar. Autoload (sin class_name).

signal partida_iniciada(nivel: Nivel)
signal partida_terminada(resultado: ResultadoPartida)

var sesion: GameSession = null

var _nivel_actual: Nivel = null
var _estaciones: Array[Estacion] = []


func iniciar_partida(nivel: Nivel, estaciones: Array[Estacion], con_ficha: bool = true) -> GameSession:
	_nivel_actual = nivel
	_estaciones = estaciones
	sesion = GameSession.new()
	sesion.partida_terminada.connect(_al_terminar)
	sesion.iniciar(nivel, estaciones, con_ficha)
	partida_iniciada.emit(nivel)
	return sesion


## Se conecta a la senal ciclo_terminado del ChefController: asi las estaciones y los pedidos avanzan despues de J1 y J2.
func actualizar(delta: float) -> void:
	if sesion != null:
		sesion.actualizar(delta)


func pausar() -> void:
	if sesion != null:
		sesion.pausar()


func reanudar() -> void:
	if sesion != null:
		sesion.reanudar()


## Reinicia el mismo nivel. La escena debe haber restaurado antes las estaciones a su estado inicial.
func reiniciar(con_ficha: bool = false) -> GameSession:
	return iniciar_partida(_nivel_actual, _estaciones, con_ficha)


func finalizar_partida() -> ResultadoPartida:
	if sesion == null:
		return null
	return sesion.resultado


func _al_terminar(resultado: ResultadoPartida) -> void:
	partida_terminada.emit(resultado)
