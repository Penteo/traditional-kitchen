extends Node
## Coordina la partida, el progreso y el Codice. Autoload (sin class_name).

signal partida_iniciada(nivel: Nivel)
signal partida_terminada(resultado: ResultadoPartida)

var sesion: GameSession = null
var progreso: ProgresoJugador = null
var codice: Codice = null

## Segundos de espera tras mover un volumen antes de guardar (agrupa las escrituras al arrastrar).
const ESPERA_GUARDADO_VOLUMEN: float = 0.5

var _nivel_actual: Nivel = null
var _estaciones: Array[Estacion] = []
var _guardado_pendiente: bool = false


## Carga el progreso y el Codice la primera vez que se necesitan (para entonces ya existen todos los autoloads).
func asegurar_inicializado() -> void:
	if progreso != null:
		return
	progreso = PersistenciaController.cargar()
	codice = Codice.new()
	codice.cargar_entradas()
	codice.cargar_desbloqueadas(progreso.entradas_codice)
	AudioController.ajustar_volumen("Musica", progreso.volumen_musica)
	AudioController.ajustar_volumen("SFX", progreso.volumen_sfx)


func obtener_progreso() -> ProgresoJugador:
	asegurar_inicializado()
	return progreso


func obtener_codice() -> Codice:
	asegurar_inicializado()
	return codice


func nivel_esta_desbloqueado(numero: int) -> bool:
	return obtener_progreso().esta_desbloqueado(numero)


func iniciar_partida(nivel: Nivel, estaciones: Array[Estacion], con_ficha: bool = true) -> GameSession:
	asegurar_inicializado()
	codice.descartar_pendientes()
	_nivel_actual = nivel
	_estaciones = estaciones
	sesion = GameSession.new()
	sesion.receta_entregada.connect(_al_entregar_receta)
	sesion.partida_terminada.connect(_al_terminar)
	sesion.iniciar(nivel, estaciones, con_ficha)
	partida_iniciada.emit(nivel)
	return sesion


## Se conecta a la senal ciclo_terminado del ChefController: las estaciones y los pedidos avanzan despues de J1 y J2.
func actualizar(delta: float) -> void:
	if sesion != null:
		sesion.actualizar(delta)


func pausar() -> void:
	if sesion != null:
		sesion.pausar()


func reanudar() -> void:
	if sesion != null:
		sesion.reanudar()


## Reinicia el mismo nivel desde cero, sin ficha. La escena debe haber restaurado antes las estaciones.
func reiniciar(con_ficha: bool = false) -> GameSession:
	return iniciar_partida(_nivel_actual, _estaciones, con_ficha)


## Salir a mitad de nivel: no se guarda nada de esa partida (los desbloqueos pendientes se pierden).
func abandonar_partida() -> void:
	if codice != null:
		codice.descartar_pendientes()
	sesion = null


func finalizar_partida() -> ResultadoPartida:
	if sesion == null:
		return null
	return sesion.resultado


func ajustar_volumen_musica(valor: float) -> void:
	asegurar_inicializado()
	progreso.volumen_musica = clampf(valor, 0.0, 1.0)
	AudioController.ajustar_volumen("Musica", progreso.volumen_musica)
	_guardar_volumen_pronto()


func ajustar_volumen_sfx(valor: float) -> void:
	asegurar_inicializado()
	progreso.volumen_sfx = clampf(valor, 0.0, 1.0)
	AudioController.ajustar_volumen("SFX", progreso.volumen_sfx)
	_guardar_volumen_pronto()


## Agrupa los cambios de volumen en una sola escritura; tambien se guarda al cerrar el juego.
func _guardar_volumen_pronto() -> void:
	if _guardado_pendiente:
		return
	_guardado_pendiente = true
	get_tree().create_timer(ESPERA_GUARDADO_VOLUMEN).timeout.connect(_guardar_volumen_ahora)


func _guardar_volumen_ahora() -> void:
	if not _guardado_pendiente:
		return
	_guardado_pendiente = false
	if progreso != null:
		PersistenciaController.guardar(progreso)


func _exit_tree() -> void:
	_guardar_volumen_ahora()


## Primera entrega aceptada de una receta: desbloquea su entrada (queda pendiente hasta terminar el nivel).
func _al_entregar_receta(receta: Receta) -> void:
	var entrada := codice.desbloquear(receta)
	if entrada != null:
		sesion.resultado.entradas_nuevas.append(entrada)


## Fin de nivel: se confirma el Codice, se actualiza el progreso y se guarda.
func _al_terminar(resultado: ResultadoPartida) -> void:
	codice.confirmar()
	progreso.entradas_codice = codice.ids_desbloqueadas()
	progreso.registrar_resultado(resultado)
	resultado.dato_curioso = _dato_curioso(resultado)
	PersistenciaController.guardar(progreso)
	partida_terminada.emit(resultado)


## Si no hay entrada nueva, se muestra el dato curioso del plato mas entregado.
func _dato_curioso(resultado: ResultadoPartida) -> String:
	if not resultado.entradas_nuevas.is_empty() or resultado.plato_mas_entregado == "":
		return ""
	var entrada := codice.entrada_por_nombre(resultado.plato_mas_entregado)
	if entrada == null:
		return ""
	return entrada.dato_curioso
