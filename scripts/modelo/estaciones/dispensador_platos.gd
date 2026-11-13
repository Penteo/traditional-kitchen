class_name DispensadorPlatos
extends Estacion
## Entrega platos vacios, con un maximo de platos en juego a la vez (en meson, en mano o en camino).
## El cupo se libera cuando un plato se entrega en la barra o se tira al cesto.

@export var max_platos: int = 3

## Las asigna GameSession al iniciar la partida; reiniciarlas tambien reinicia el conteo.
var recetas: Array[Receta] = []:
	set(valor):
		recetas = valor
		_en_juego = 0
		queue_redraw()

var _en_juego: int = 0


func _ready() -> void:
	nombre = "Dispensador"
	color_placeholder = Color(0.85, 0.85, 0.9)
	super()


func disponibles() -> int:
	return maxi(0, max_platos - _en_juego)


## Los ingredientes se ponen en los platos, no en el dispensador.
func acepta(_item: Item) -> bool:
	return false


func recibir(_item: Item) -> bool:
	return false


func puede_entregar() -> bool:
	return _en_juego < max_platos


func retirar() -> Item:
	if not puede_entregar():
		return null
	var plato := Plato.new()
	plato.recetas = recetas
	plato.consumido.connect(_al_consumir_plato, CONNECT_ONE_SHOT)
	_en_juego += 1
	item_cambiado.emit()
	queue_redraw()
	return plato


func _al_consumir_plato() -> void:
	_en_juego = maxi(0, _en_juego - 1)
	item_cambiado.emit()
	queue_redraw()


## Insignia con los platos que todavia se pueden sacar (roja si no queda ninguno).
func _dibujar_extra(tamano: Vector2) -> void:
	var cantidad := disponibles()
	var centro := Vector2(tamano.x / 2.0 - 20.0, -tamano.y / 2.0 + 20.0)
	var fondo := Color(0.2, 0.55, 0.3) if cantidad > 0 else Color(0.75, 0.2, 0.2)
	draw_circle(centro, 17.0, fondo)
	draw_arc(centro, 17.0, 0.0, TAU, 24, Color.WHITE, 2.0, true)
	draw_string(ThemeDB.fallback_font, centro + Vector2(-17.0, 7.0), str(cantidad), HORIZONTAL_ALIGNMENT_CENTER, 34.0, 20, Color.WHITE)