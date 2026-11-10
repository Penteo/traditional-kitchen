class_name Chef
extends CharacterBody2D
## Chef controlado por un jugador. Se desplaza y lleva como máximo un ítem (R1).

signal item_cambiado

enum Direccion { ARRIBA, ABAJO, IZQUIERDA, DERECHA }

@export var numero_jugador: int = 1
@export var color: Color = Color.WHITE
@export var parametros: ParametrosChef

var direccion: Direccion = Direccion.ABAJO
var item_en_mano: Item = null

@onready var _zona: Area2D = $ZonaInteraccion


func _enter_tree() -> void:
	add_to_group("chefs")


func _ready() -> void:
	($Colision.shape as CircleShape2D).radius = parametros.radio_colision
	($ZonaInteraccion/Colision.shape as CircleShape2D).radius = parametros.radio_zona_interaccion
	_actualizar_zona()
	queue_redraw()


func mover(vector: Vector2) -> void:
	velocity = vector * parametros.velocidad
	move_and_slide()
	if vector != Vector2.ZERO:
		var nueva := _direccion_dominante(vector)
		if nueva != direccion:
			direccion = nueva
			_actualizar_zona()
			queue_redraw()


func sostiene_item() -> bool:
	return item_en_mano != null


## R1: si ya lleva un ítem, no recoge otro y la acción no tiene efecto.
func tomar(item: Item) -> bool:
	if item_en_mano != null:
		return false
	item_en_mano = item
	item_cambiado.emit()
	queue_redraw()
	return true


func soltar() -> Item:
	var item := item_en_mano
	item_en_mano = null
	item_cambiado.emit()
	queue_redraw()
	return item


## Estación más cercana dentro de la zona de interacción (delante del chef).
func estacion_objetivo() -> Estacion:
	var mejor: Estacion = null
	var mejor_distancia := INF
	for cuerpo in _zona.get_overlapping_bodies():
		var estacion := cuerpo as Estacion
		if estacion == null:
			continue
		var distancia := global_position.distance_to(estacion.global_position)
		if distancia < mejor_distancia:
			mejor_distancia = distancia
			mejor = estacion
	return mejor


func _actualizar_zona() -> void:
	_zona.position = _vector_de(direccion) * (parametros.alcance_interaccion - parametros.radio_zona_interaccion)


func _direccion_dominante(vector: Vector2) -> Direccion:
	if absf(vector.x) > absf(vector.y):
		return Direccion.DERECHA if vector.x > 0.0 else Direccion.IZQUIERDA
	return Direccion.ABAJO if vector.y > 0.0 else Direccion.ARRIBA


func _vector_de(d: Direccion) -> Vector2:
	match d:
		Direccion.ARRIBA:
			return Vector2.UP
		Direccion.ABAJO:
			return Vector2.DOWN
		Direccion.IZQUIERDA:
			return Vector2.LEFT
	return Vector2.RIGHT


# Dibujo provisional hasta tener el arte final.
func _draw() -> void:
	draw_circle(Vector2.ZERO, parametros.radio_colision, color)
	draw_line(Vector2.ZERO, _vector_de(direccion) * parametros.radio_colision, Color.WHITE, 4.0)
	if item_en_mano != null:
		var posicion := Vector2(0.0, -parametros.radio_colision - 24.0)
		draw_circle(posicion, 16.0, item_en_mano.color())
		draw_string(ThemeDB.fallback_font, posicion + Vector2(-60.0, -24.0), item_en_mano.etiqueta(), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 20)
