class_name Ingrediente
extends Item
## Ingrediente con su tipo y su estado actual.

enum Tipo { MASA, QUESO, EMPANADA, PAPA, CARNE }
enum Estado { CRUDO, PICADO, COCIDO, QUEMADO }

const NOMBRES: Array[String] = ["masa", "queso", "empanada", "papa", "carne"]
const ESTADOS: Array[String] = ["crudo", "picado", "cocido", "quemado"]
const COLORES: Array[Color] = [
	Color(0.95, 0.85, 0.5),
	Color(1.0, 0.95, 0.4),
	Color(0.9, 0.6, 0.3),
	Color(0.8, 0.7, 0.5),
	Color(0.7, 0.3, 0.3),
]

var tipo: Tipo
var estado: Estado


func _init(p_tipo: Tipo = Tipo.MASA, p_estado: Estado = Estado.CRUDO) -> void:
	tipo = p_tipo
	estado = p_estado


func etiqueta() -> String:
	return "%s (%s)" % [NOMBRES[tipo], ESTADOS[estado]]


func color() -> Color:
	return COLORES[tipo]
