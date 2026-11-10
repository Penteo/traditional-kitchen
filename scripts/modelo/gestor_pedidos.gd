class_name GestorPedidos
extends RefCounted
## Genera los pedidos con la secuencia fija del nivel y controla su cupo y su vencimiento.

signal pedido_generado(pedido: Pedido)
signal pedido_entregado(pedido: Pedido)
signal pedido_vencido(pedido: Pedido)
signal pedido_rechazado(pedido: Pedido)

var nivel: Nivel
## Pedidos visibles, del mas antiguo al mas reciente.
var activos: Array[Pedido] = []
## Pedidos que ya les toca aparecer pero esperan a que se libere un cupo.
var en_espera: Array[Receta] = []

var _secuencia: Array[Receta] = []
var _indice_programado: int = 0
var _proximo_programado: float = 0.0
var _contador: int = 0


func iniciar(p_nivel: Nivel) -> void:
	nivel = p_nivel
	activos.clear()
	en_espera.clear()
	_secuencia = p_nivel.secuencia_tipada()
	_indice_programado = 0
	_proximo_programado = p_nivel.primer_pedido
	_contador = 0


## Paso (4) del orden de resolucion: vencimiento de pedidos y llegada de pedidos nuevos.
func actualizar(delta: float, tiempo_transcurrido: float) -> void:
	_avanzar_pedidos(delta)
	_programar(tiempo_transcurrido)
	_admitir(tiempo_transcurrido)


## Pedido activo mas antiguo que pide esa receta, o null.
func pedido_para(receta: Receta) -> Pedido:
	for pedido in activos:
		if pedido.receta == receta:
			return pedido
	return null


func pedido_mas_antiguo() -> Pedido:
	if activos.is_empty():
		return null
	return activos[0]


func entregar(pedido: Pedido) -> void:
	activos.erase(pedido)
	pedido.estado = Pedido.Estado.ENTREGADO
	pedido_entregado.emit(pedido)


## El pedido activo mas antiguo se cierra como rechazado.
func rechazar_mas_antiguo() -> Pedido:
	var pedido := pedido_mas_antiguo()
	if pedido == null:
		return null
	activos.erase(pedido)
	pedido.estado = Pedido.Estado.RECHAZADO
	pedido_rechazado.emit(pedido)
	return pedido


## Al terminar el tiempo, los pendientes se descartan sin sumar ni restar puntos.
func descartar_pendientes() -> void:
	activos.clear()
	en_espera.clear()


func _avanzar_pedidos(delta: float) -> void:
	for pedido in activos.duplicate():
		if pedido.actualizar(delta):
			activos.erase(pedido)
			pedido_vencido.emit(pedido)


func _limite_de_aparicion() -> float:
	return nivel.duracion - nivel.ventana_sin_pedidos


func _programar(tiempo_transcurrido: float) -> void:
	while _indice_programado < _secuencia.size() and tiempo_transcurrido >= _proximo_programado:
		if _proximo_programado < _limite_de_aparicion():
			en_espera.append(_secuencia[_indice_programado])
		_indice_programado += 1
		_proximo_programado += nivel.intervalo_pedidos


func _admitir(tiempo_transcurrido: float) -> void:
	if tiempo_transcurrido >= _limite_de_aparicion():
		en_espera.clear()
		return
	while not en_espera.is_empty() and activos.size() < nivel.cupo_pedidos:
		var receta: Receta = en_espera.pop_front()
		_contador += 1
		var pedido := Pedido.new(receta, _contador)
		activos.append(pedido)
		pedido_generado.emit(pedido)
