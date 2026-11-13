class_name Plato
extends Item
## Plato con ingredientes ya procesados. Nace vacio en el dispensador y se llena sobre un meson
## o en la mano del chef. Se valida por composicion, sin orden de armado.

## Se emite una sola vez cuando el plato sale de juego (entregado o tirado al cesto).
signal consumido

## Recetas del nivel: deciden que ingredientes caben en este plato. Las asigna el dispensador.
var recetas: Array[Receta] = []
var componentes: Array[Ingrediente] = []

var _consumido: bool = false


func agregar(ingrediente: Ingrediente) -> void:
	componentes.append(ingrediente)


func esta_vacio() -> bool:
	return componentes.is_empty()


## True si el ingrediente, sumado al contenido actual, sigue siendo parte de alguna receta.
func acepta(ingrediente: Ingrediente) -> bool:
	var tentativo := contenido()
	var clave := ingrediente.clave()
	tentativo[clave] = int(tentativo.get(clave, 0)) + 1
	for receta in recetas:
		if receta.admite(tentativo):
			return true
	return false


## Saca el plato de juego y libera su cupo en el dispensador. Solo avisa una vez.
func consumir() -> void:
	if _consumido:
		return
	_consumido = true
	consumido.emit()


## Contenido del plato: clave (tipo + estado) -> cantidad.
func contenido() -> Dictionary:
	var resultado := {}
	for componente in componentes:
		var clave := componente.clave()
		resultado[clave] = int(resultado.get(clave, 0)) + 1
	return resultado


func coincide(receta: Receta) -> bool:
	return receta.coincide_con(contenido())


func etiqueta() -> String:
	if componentes.is_empty():
		return "plato vacio"
	var nombres := PackedStringArray()
	for componente in componentes:
		nombres.append(Ingrediente.NOMBRES[componente.tipo])
	return "plato: " + ", ".join(nombres)


func color() -> Color:
	return Color(0.95, 0.95, 0.95)