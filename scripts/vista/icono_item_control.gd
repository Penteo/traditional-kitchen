class_name IconoItemControl
extends Control
## Control que muestra el icono de un item (por ejemplo, el de la mano de cada chef en el HUD).

var item: Item = null


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Devuelve true si hay arte para ese item; si no, quien llama conserva su indicador de color.
func establecer(nuevo: Item) -> bool:
	item = nuevo
	queue_redraw()
	return nuevo != null and IconoItem.hay_arte(nuevo)


func _draw() -> void:
	if item != null:
		IconoItem.dibujar(self, item, size / 2.0, minf(size.x, size.y))
