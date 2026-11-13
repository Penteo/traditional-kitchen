class_name CestoBasura
extends Estacion
## Acepta cualquier item y lo descarta. Si es un plato, libera su cupo en el dispensador.


func _ready() -> void:
	super()
	nombre = "Cesto"
	queue_redraw()


func acepta(_item: Item) -> bool:
	return true


func recibir(item: Item) -> bool:
	var plato := item as Plato
	if plato != null:
		plato.consumir()
	item_cambiado.emit()
	return true