class_name GameSession
extends RefCounted
## Una partida: estados, reloj unico, pausa y orden de resolucion.
## Orden por ciclo: (1) J1, (2) J2 [ChefController], (3) estaciones, (4) pedidos, (5) puntaje por evento.

signal estado_cambiado(nuevo: Estado)
signal tiempo_actualizado(restante: float)
signal cuenta_atras_cambiada(valor: int)
signal pausa_cambiada(pausada: bool)
signal receta_entregada(receta: Receta)
signal partida_terminada(resultado: ResultadoPartida)

enum Estado { SELECCION_NIVEL, BRIEFING, CUENTA_ATRAS, SERVICIO, FIN_TIEMPO, RESULTADOS }

const DURACION_FICHA: float = 5.0
const DURACION_CUENTA_ATRAS: float = 3.0

var estado: Estado = Estado.SELECCION_NIVEL
var nivel: Nivel
var tiempo_restante: float = 0.0
var pausada: bool = false
var gestor_pedidos: GestorPedidos = GestorPedidos.new()
var puntuacion: Puntuacion = Puntuacion.new()
var resultado: ResultadoPartida

var _estaciones: Array[Estacion] = []
var _recetas: Array[Receta] = []
var _tiempo_estado: float = 0.0
var _tiempo_transcurrido: float = 0.0
var _ultimo_valor_cuenta: int = 0


func esta_terminada() -> bool:
	return estado == Estado.RESULTADOS


## Prepara la partida. Con ficha empieza en BRIEFING (hasta 5 s, omitible); sin ficha, directo a la cuenta atras.
func iniciar(p_nivel: Nivel, estaciones: Array[Estacion], con_ficha: bool = true) -> void:
	nivel = p_nivel
	_estaciones = estaciones
	_recetas = p_nivel.recetas_disponibles()
	tiempo_restante = p_nivel.duracion
	_tiempo_transcurrido = 0.0
	pausada = false
	puntuacion.reiniciar()
	gestor_pedidos.iniciar(p_nivel)
	gestor_pedidos.pedido_vencido.connect(_al_vencer)
	resultado = ResultadoPartida.new()
	resultado.nivel = p_nivel
	resultado.cuota = p_nivel.cuota
	_conectar_estaciones()
	if con_ficha:
		_cambiar_estado(Estado.BRIEFING)
	else:
		_empezar_cuenta_atras()


func omitir_briefing() -> void:
	if estado == Estado.BRIEFING:
		_empezar_cuenta_atras()


## La pausa detiene el reloj y todos los temporizadores; al reanudar continuan desde el mismo valor.
func pausar() -> void:
	if estado == Estado.SERVICIO and not pausada:
		pausada = true
		pausa_cambiada.emit(true)


func reanudar() -> void:
	if pausada:
		pausada = false
		pausa_cambiada.emit(false)


func actualizar(delta: float) -> void:
	if pausada:
		return
	match estado:
		Estado.BRIEFING:
			_tiempo_estado += delta
			if _tiempo_estado >= DURACION_FICHA:
				_empezar_cuenta_atras()
		Estado.CUENTA_ATRAS:
			_tiempo_estado += delta
			var valor := ceili(DURACION_CUENTA_ATRAS - _tiempo_estado)
			if valor > 0 and valor != _ultimo_valor_cuenta:
				_ultimo_valor_cuenta = valor
				cuenta_atras_cambiada.emit(valor)
			if _tiempo_estado >= DURACION_CUENTA_ATRAS:
				_cambiar_estado(Estado.SERVICIO)
		Estado.SERVICIO:
			_servir(delta)


func _servir(delta: float) -> void:
	var paso := minf(delta, tiempo_restante)
	_tiempo_transcurrido += paso
	tiempo_restante -= paso
	for estacion in _estaciones:
		estacion.actualizar(paso)
	gestor_pedidos.actualizar(paso, _tiempo_transcurrido)
	tiempo_actualizado.emit(tiempo_restante)
	if tiempo_restante <= 0.0:
		_terminar()


func _terminar() -> void:
	_cambiar_estado(Estado.FIN_TIEMPO)
	gestor_pedidos.descartar_pendientes()
	resultado.puntaje = puntuacion.puntos
	resultado.estrellas = puntuacion.estrellas(nivel.cuota)
	resultado.cuota_cumplida = puntuacion.puntos >= nivel.cuota
	_cambiar_estado(Estado.RESULTADOS)
	partida_terminada.emit(resultado)


func _empezar_cuenta_atras() -> void:
	_cambiar_estado(Estado.CUENTA_ATRAS)
	_ultimo_valor_cuenta = ceili(DURACION_CUENTA_ATRAS)
	cuenta_atras_cambiada.emit(_ultimo_valor_cuenta)


func _cambiar_estado(nuevo: Estado) -> void:
	estado = nuevo
	_tiempo_estado = 0.0
	estado_cambiado.emit(nuevo)


func _conectar_estaciones() -> void:
	for estacion in _estaciones:
		var barra := estacion as BarraEntrega
		if barra != null:
			barra.plato_entregado.connect(_al_entregar_plato)
		var coccion := estacion as EstacionCoccion
		if coccion != null:
			coccion.alimento_quemado.connect(_al_quemarse)
		var dispensador := estacion as DispensadorPlatos
		if dispensador != null:
			dispensador.recetas = _recetas


func _receta_de(plato: Plato) -> Receta:
	for receta in _recetas:
		if plato.coincide(receta):
			return receta
	return null


## Evalua un plato entregado contra los pedidos activos (secuencia: Cocccion, entrega y puntuacion).
func _al_entregar_plato(plato: Plato) -> void:
	var receta := _receta_de(plato)
	var pedido: Pedido = null
	if receta != null:
		pedido = gestor_pedidos.pedido_para(receta)
	if pedido != null:
		gestor_pedidos.entregar(pedido)
		puntuacion.registrar_entrega(pedido)
		resultado.registrar_entrega(receta)
		receta_entregada.emit(receta)
	elif not gestor_pedidos.activos.is_empty():
		var rechazado := gestor_pedidos.rechazar_mas_antiguo()
		puntuacion.registrar_rechazo(rechazado)
		resultado.rechazados += 1
	# Sin pedidos activos: el plato se descarta sin penalizacion.


func _al_vencer(pedido: Pedido) -> void:
	puntuacion.registrar_vencido(pedido)
	resultado.vencidos += 1


func _al_quemarse() -> void:
	resultado.quemados += 1
