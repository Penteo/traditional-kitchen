class_name Receta
extends Resource
## Datos de una receta (Tablas 16 y 17 del GDD). Solo lectura durante la partida.

@export var nombre: String = ""
@export var region: String = "Colombia"
@export var componentes: PackedInt32Array = PackedInt32Array()
@export var estados_componentes: PackedInt32Array = PackedInt32Array()
@export var unidades_por_pedido: int = 1
@export var valor_base: int = 0
@export var limite_tiempo: float = 0.0
@export var simplificacion: String = ""


## Lo que pide la receta: clave (tipo + estado) -> cantidad.
func requeridos() -> Dictionary:
	var resultado := {}
	for i in componentes.size():
		var clave := Ingrediente.hacer_clave(componentes[i], estados_componentes[i])
		resultado[clave] = int(resultado.get(clave, 0)) + unidades_por_pedido
	return resultado


## True si el contenido solo usa componentes de la receta y no supera lo que pide.
func admite(contenido: Dictionary) -> bool:
	var pedido := requeridos()
	for clave in contenido:
		if not pedido.has(clave) or int(contenido[clave]) > int(pedido[clave]):
			return false
	return true


## True si el contenido coincide exactamente con la receta (sin orden de armado).
func coincide_con(contenido: Dictionary) -> bool:
	var pedido := requeridos()
	if contenido.size() != pedido.size():
		return false
	for clave in pedido:
		if int(contenido.get(clave, 0)) != int(pedido[clave]):
			return false
	return true
