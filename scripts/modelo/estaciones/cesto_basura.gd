class_name CestoBasura
extends Estacion
## Acepta cualquier ítem y lo descarta.


func _ready() -> void:
	super()
	nombre = "Cesto"
	queue_redraw()


func acepta(_item: Item) -> bool:
	return true


func recibir(_item: Item) -> bool:
	item_cambiado.emit()
	return true
