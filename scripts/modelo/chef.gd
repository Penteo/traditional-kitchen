class_name Chef
extends CharacterBody2D
## Chef controlado por un jugador. Se desplaza y lleva como maximo un item (R1). El dibujo vive en ChefView.

signal item_cambiado
## Una accion sin efecto: ChefView hace parpadear el icono del item (Tabla 23, SFX3).
signal accion_invalida

enum Direccion { ARRIBA, ABAJO, IZQUIERDA, DERECHA }

@export var numero_jugador: int = 1
@export var color: Color = Color.WHITE
@export var parametros: ParametrosChef

var direccion: Direccion = Direccion.ABAJO
var item_en_mano: Item = null
## Tabla en la que este chef esta cortando ahora mismo (null si no corta).
var tabla_cortando: TablaCortar = null

@onready var _zona: Area2D = $ZonaInteraccion


func _enter_tree() -> void:
	add_to_group("chefs")


func _ready() -> void:
	($Colision.shape as CircleShape2D).radius = parametros.radio_colision
	($ZonaInteraccion/Colision.shape as CircleShape2D).radius = parametros.radio_zona_interaccion
	_actualizar_zona()


func mover(vector: Vector2) -> void:
	if esta_cortando():
		velocity = Vector2.ZERO
		return
	velocity = vector * parametros.velocidad
	move_and_slide()
	if vector != Vector2.ZERO:
		var nueva := _direccion_dominante(vector)
		if nueva != direccion:
			direccion = nueva
			_actualizar_zona()


## Se queda quieto (pausa, cuenta atras y resultados).
func detener() -> void:
	velocity = Vector2.ZERO


## Cortando: no se mueve hasta que la tabla termine o alguien retire el ingrediente.
func esta_cortando() -> bool:
	if tabla_cortando != null and not tabla_cortando.cortando:
		tabla_cortando = null
	return tabla_cortando != null


func sostiene_item() -> bool:
	return item_en_mano != null


## R1: si ya lleva un ítem, no recoge otro y la acción no tiene efecto.
func tomar(item: Item) -> bool:
	if item_en_mano != null:
		return false
	item_en_mano = item
	item_cambiado.emit()
	return true


func soltar() -> Item:
	var item := item_en_mano
	item_en_mano = null
	item_cambiado.emit()
	return item


func marcar_accion_invalida() -> void:
	accion_invalida.emit()


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


func vector_direccion() -> Vector2:
	return _vector_de(direccion)


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
