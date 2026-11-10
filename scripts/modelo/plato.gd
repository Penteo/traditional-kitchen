class_name Plato
extends Item
## Plato armado con ingredientes ya procesados. Se valida por composicion, sin orden de armado.

var componentes: Array[Ingrediente] = []


func agregar(ingrediente: Ingrediente) -> void:
	componentes.append(ingrediente)


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
	var nombres := PackedStringArray()
	for componente in componentes:
		nombres.append(Ingrediente.NOMBRES[componente.tipo])
	return "plato: " + ", ".join(nombres)


func color() -> Color:
	return Color(0.95, 0.95, 0.95)
