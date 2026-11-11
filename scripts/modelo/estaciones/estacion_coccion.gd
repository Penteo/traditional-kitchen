class_name EstacionCoccion
extends Estacion
## Base de plancha, freidora y olla. Cocina, avisa al terminar, avisa 3 s antes de quemarse y quema.

signal estado_cambiado(nuevo: Estado)
signal alimento_quemado

enum Estado { VACIA, PROCESANDO, LISTO, PELIGRO, QUEMADO }

## Duracion del destello al quemarse (efecto visual de la seccion 6.2).
const DURACION_DESTELLO: float = 0.6

@export var parametros: ParametrosCoccion

var estado: Estado = Estado.VACIA
var tiempo_coccion_actual: float = 0.0
var tiempo_desde_listo: float = 0.0
var tipos_aceptados: Array[Ingrediente.Tipo] = []
var estado_requerido: Ingrediente.Estado = Ingrediente.Estado.CRUDO
var items_para_iniciar: int = 1

var _destello: float = 0.0


## Cada estacion concreta fija aqui lo que acepta.
func _configurar() -> void:
	pass


func _ready() -> void:
	_configurar()
	capacidad = items_para_iniciar
	add_to_group("estaciones_temporizadas")
	super()


func acepta(item: Item) -> bool:
	if estado != Estado.VACIA or items.size() >= capacidad:
		return false
	var ingrediente := item as Ingrediente
	if ingrediente == null or ingrediente.estado != estado_requerido:
		return false
	if not tipos_aceptados.has(ingrediente.tipo):
		return false
	for existente in items:
		if (existente as Ingrediente).tipo == ingrediente.tipo:
			return false
	return true


func recibir(item: Item) -> bool:
	if not super(item):
		return false
	if items.size() >= items_para_iniciar:
		tiempo_coccion_actual = 0.0
		tiempo_desde_listo = 0.0
		_cambiar_estado(Estado.PROCESANDO)
	return true


func actualizar(delta: float) -> void:
	if _destello > 0.0:
		_destello = maxf(0.0, _destello - delta / DURACION_DESTELLO)
		queue_redraw()
	match estado:
		Estado.PROCESANDO:
			tiempo_coccion_actual += delta
			if tiempo_coccion_actual >= parametros.tiempo_coccion:
				tiempo_desde_listo = tiempo_coccion_actual - parametros.tiempo_coccion
				items = _resultado_cocido()
				_cambiar_estado(Estado.LISTO)
		Estado.LISTO, Estado.PELIGRO:
			tiempo_desde_listo += delta
			if tiempo_desde_listo >= parametros.ventana_quemado:
				_quemar()
			elif estado == Estado.LISTO and tiempo_desde_listo >= parametros.ventana_quemado - parametros.aviso_antes_de_quemarse:
				_cambiar_estado(Estado.PELIGRO)
	if estado != Estado.VACIA:
		queue_redraw()


## Retirar a mitad de coccion devuelve el ítem tal como estaba y reinicia el temporizador.
func retirar() -> Item:
	var item: Item = items.pop_front()
	if estado == Estado.PROCESANDO:
		tiempo_coccion_actual = 0.0
		_cambiar_estado(Estado.VACIA)
	elif estado in [Estado.LISTO, Estado.PELIGRO, Estado.QUEMADO]:
		_cambiar_estado(Estado.VACIA)
	item_cambiado.emit()
	queue_redraw()
	return item


## Resultado de cocinar. Las estaciones con otro resultado (la olla) lo sobrescriben.
func _resultado_cocido() -> Array[Item]:
	for item in items:
		(item as Ingrediente).estado = Ingrediente.Estado.COCIDO
	return items


func _quemar() -> void:
	for item in items:
		(item as Ingrediente).estado = Ingrediente.Estado.QUEMADO
	_destello = 1.0
	alimento_quemado.emit()
	_cambiar_estado(Estado.QUEMADO)


func _cambiar_estado(nuevo: Estado) -> void:
	estado = nuevo
	estado_cambiado.emit(nuevo)
	queue_redraw()


func _dibujar_extra(tamano: Vector2) -> void:
	var ancho := tamano.x - 20.0
	var origen := Vector2(-ancho / 2.0, tamano.y / 2.0 - 10.0)
	var fraccion := 0.0
	match estado:
		Estado.PROCESANDO:
			fraccion = tiempo_coccion_actual / parametros.tiempo_coccion
		Estado.LISTO, Estado.PELIGRO, Estado.QUEMADO:
			fraccion = 1.0
	draw_rect(Rect2(origen, Vector2(ancho, 8.0)), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(origen, Vector2(ancho * clampf(fraccion, 0.0, 1.0), 8.0)), Color.WHITE)
	# Iconos de alerta provisionales: verde = listo, ambar parpadeante = peligro, negro = quemado.
	var alerta := Color(0, 0, 0, 0)
	match estado:
		Estado.LISTO:
			alerta = Color.GREEN
		Estado.PELIGRO:
			if int(Time.get_ticks_msec() / 250.0) % 2 == 0:
				alerta = Color(1.0, 0.7, 0.0)
		Estado.QUEMADO:
			alerta = Color.BLACK
	if alerta.a > 0.0:
		draw_circle(Vector2(tamano.x / 2.0 - 16.0, -tamano.y / 2.0 + 16.0), 12.0, alerta)
	# Destello al quemarse: un velo blanco que se desvanece.
	if _destello > 0.0:
		draw_rect(Rect2(-tamano / 2.0, tamano), Color(1.0, 1.0, 1.0, 0.85 * _destello))
