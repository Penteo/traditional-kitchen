class_name Surtidor
extends Estacion
## Caja ilimitada: entrega 1 unidad cruda por acción y no recibe ítems.

@export var tipo: Ingrediente.Tipo = Ingrediente.Tipo.QUESO


func _ready() -> void:
	super()
	nombre = "Caja de " + Ingrediente.NOMBRES[tipo]
	color_placeholder = Ingrediente.COLORES[tipo]
	queue_redraw()


func acepta(_item: Item) -> bool:
	return false


func puede_entregar() -> bool:
	return true


func retirar() -> Item:
	return Ingrediente.new(tipo, Ingrediente.Estado.CRUDO)
