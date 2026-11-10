class_name Ingrediente
extends Item
## Ingrediente con su tipo y su estado actual. MUTE es el resultado de cocinar papa y carne en la olla.

enum Tipo { MASA, QUESO, EMPANADA, PAPA, CARNE, MUTE }
enum Estado { CRUDO, PICADO, COCIDO, QUEMADO }

const NOMBRES: Array[String] = ["masa", "queso", "empanada", "papa", "carne", "mute"]
const ESTADOS: Array[String] = ["crudo", "picado", "cocido", "quemado"]
const COLORES: Array[Color] = [
	Color(0.95, 0.85, 0.5),
	Color(1.0, 0.95, 0.4),
	Color(0.9, 0.6, 0.3),
	Color(0.8, 0.7, 0.5),
	Color(0.7, 0.3, 0.3),
	Color(0.6, 0.4, 0.2),
]

var tipo: Tipo
var estado: Estado


func _init(p_tipo: Tipo = Tipo.MASA, p_estado: Estado = Estado.CRUDO) -> void:
	tipo = p_tipo
	estado = p_estado


## Clave que identifica "tipo + estado". Sirve para comparar la composicion de un plato con una receta.
static func hacer_clave(p_tipo: int, p_estado: int) -> String:
	return "%d_%d" % [p_tipo, p_estado]


func clave() -> String:
	return hacer_clave(tipo, estado)


func etiqueta() -> String:
	return "%s (%s)" % [NOMBRES[tipo], ESTADOS[estado]]


func color() -> Color:
	return COLORES[tipo]
