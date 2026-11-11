class_name TablaCortar
extends Estacion
## Corta queso, papa y carne con una sola pulsacion de Procesar. No se quema.

signal corte_iniciado

@export var parametros: ParametrosTabla

var cortando: bool = false
var progreso: float = 0.0
var tiempo_total: float = 0.0


func _ready() -> void:
	nombre = "Tabla de cortar"
	color_placeholder = Color(0.7, 0.55, 0.35)
	add_to_group("estaciones_temporizadas")
	super()


func acepta(item: Item) -> bool:
	if esta_ocupada():
		return false
	var ingrediente := item as Ingrediente
	if ingrediente == null or ingrediente.estado != Ingrediente.Estado.CRUDO:
		return false
	return ingrediente.tipo in [Ingrediente.Tipo.QUESO, Ingrediente.Tipo.PAPA, Ingrediente.Tipo.CARNE]


func procesar() -> void:
	if items.is_empty() or cortando:
		return
	var ingrediente := items[0] as Ingrediente
	if ingrediente.estado != Ingrediente.Estado.CRUDO:
		return
	cortando = true
	progreso = 0.0
	tiempo_total = parametros.tiempo_para(ingrediente.tipo)
	corte_iniciado.emit()
	queue_redraw()


func actualizar(delta: float) -> void:
	if not cortando:
		return
	progreso += delta
	if progreso >= tiempo_total:
		cortando = false
		(items[0] as Ingrediente).estado = Ingrediente.Estado.PICADO
		item_cambiado.emit()
	queue_redraw()


## Retirar a mitad de corte devuelve el ítem tal como estaba (crudo) y reinicia el corte.
func retirar() -> Item:
	cortando = false
	progreso = 0.0
	return super()


func _dibujar_extra(tamano: Vector2) -> void:
	if not cortando:
		return
	var ancho := tamano.x - 20.0
	var origen := Vector2(-ancho / 2.0, tamano.y / 2.0 - 10.0)
	draw_rect(Rect2(origen, Vector2(ancho, 8.0)), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(origen, Vector2(ancho * clampf(progreso / tiempo_total, 0.0, 1.0), 8.0)), Color.WHITE)
