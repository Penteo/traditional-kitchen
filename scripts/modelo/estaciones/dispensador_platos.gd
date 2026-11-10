class_name DispensadorPlatos
extends Estacion
## Punto de ensamblaje (R2: excepcion). Acumula los componentes de un solo plato en armado.

var recetas: Array[Receta] = []
var plato_en_armado: Plato = null


func _ready() -> void:
	nombre = "Dispensador"
	color_placeholder = Color(0.85, 0.85, 0.9)
	capacidad = 99
	super()


## Solo acepta ingredientes procesados que, sumados al contenido actual, sigan siendo parte de alguna receta.
func acepta(item: Item) -> bool:
	var ingrediente := item as Ingrediente
	if ingrediente == null:
		return false
	var tentativo := _contenido_actual()
	var clave := ingrediente.clave()
	tentativo[clave] = int(tentativo.get(clave, 0)) + 1
	for receta in recetas:
		if receta.admite(tentativo):
			return true
	return false


func agregar_ingrediente(ingrediente: Ingrediente) -> bool:
	if not acepta(ingrediente):
		return false
	if plato_en_armado == null:
		plato_en_armado = Plato.new()
	plato_en_armado.agregar(ingrediente)
	_sincronizar()
	return true


func recibir(item: Item) -> bool:
	var ingrediente := item as Ingrediente
	if ingrediente == null:
		return false
	return agregar_ingrediente(ingrediente)


## Receta que el plato en armado ya completa, o null si todavia no esta completo.
func receta_completada() -> Receta:
	if plato_en_armado == null:
		return null
	for receta in recetas:
		if plato_en_armado.coincide(receta):
			return receta
	return null


## Solo se puede retirar un plato completo.
func puede_entregar() -> bool:
	return receta_completada() != null


func retirar() -> Item:
	return retirar_plato()


func retirar_plato() -> Plato:
	if receta_completada() == null:
		return null
	var plato := plato_en_armado
	plato_en_armado = null
	_sincronizar()
	return plato


func _contenido_actual() -> Dictionary:
	if plato_en_armado == null:
		return {}
	return plato_en_armado.contenido()


func _sincronizar() -> void:
	items.clear()
	if plato_en_armado != null:
		for componente in plato_en_armado.componentes:
			items.append(componente)
	item_cambiado.emit()
	queue_redraw()


func _dibujar_extra(tamano: Vector2) -> void:
	var completada := receta_completada()
	if completada != null:
		draw_string(ThemeDB.fallback_font, Vector2(-tamano.x / 2.0, tamano.y / 2.0 + 20.0), "LISTO: " + completada.nombre, HORIZONTAL_ALIGNMENT_CENTER, tamano.x, 16, Color.GREEN)
