class_name Estacion
extends StaticBody2D
## Base de todas las estaciones. Admite un solo ítem a la vez (R2), salvo excepciones por estación.

signal item_cambiado

@export var nombre: String = "Estacion"
@export var color_placeholder: Color = Color(0.5, 0.5, 0.5)
@export var capacidad: int = 1

var items: Array[Item] = []


func _ready() -> void:
	queue_redraw()


func esta_ocupada() -> bool:
	return items.size() >= capacidad


func acepta(_item: Item) -> bool:
	return not esta_ocupada()


func puede_entregar() -> bool:
	return not items.is_empty()


func recibir(item: Item) -> bool:
	if not acepta(item):
		return false
	items.append(item)
	item_cambiado.emit()
	queue_redraw()
	return true


func retirar() -> Item:
	var item: Item = items.pop_front()
	item_cambiado.emit()
	queue_redraw()
	return item


# Dibujo provisional hasta tener el arte final.
func _draw() -> void:
	var tamano := ($Colision.shape as RectangleShape2D).size
	draw_rect(Rect2(-tamano / 2.0, tamano), color_placeholder)
	draw_string(ThemeDB.fallback_font, Vector2(-tamano.x / 2.0, -tamano.y / 2.0 - 8.0), nombre, HORIZONTAL_ALIGNMENT_CENTER, tamano.x, 20)
	if not items.is_empty():
		draw_circle(Vector2.ZERO, 18.0, items[0].color())
		draw_string(ThemeDB.fallback_font, Vector2(-tamano.x / 2.0, 36.0), items[0].etiqueta(), HORIZONTAL_ALIGNMENT_CENTER, tamano.x, 18)
