class_name BarraEntrega
extends Estacion
## Barra de entrega: solo recibe platos armados. No decide nada: avisa con una senal.

signal plato_entregado(plato: Plato)


func _ready() -> void:
	nombre = "Barra de entrega"
	color_placeholder = Color(0.4, 0.75, 0.45)
	super()


func acepta(item: Item) -> bool:
	return item is Plato


func puede_entregar() -> bool:
	return false


func recibir(item: Item) -> bool:
	var plato := item as Plato
	if plato == null:
		return false
	plato_entregado.emit(plato)
	return true
