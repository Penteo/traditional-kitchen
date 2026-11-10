class_name Chef
extends CharacterBody2D
## Chef controlado por un jugador. Recibe el vector de movimiento y se desplaza.

enum Direccion { ARRIBA, ABAJO, IZQUIERDA, DERECHA }

@export var numero_jugador: int = 1
@export var color: Color = Color.WHITE
@export var parametros: ParametrosChef

var direccion: Direccion = Direccion.ABAJO


func _enter_tree() -> void:
	add_to_group("chefs")


func _ready() -> void:
	var forma := $Colision.shape as CircleShape2D
	forma.radius = parametros.radio_colision
	queue_redraw()


func mover(vector: Vector2) -> void:
	velocity = vector * parametros.velocidad
	move_and_slide()
	if vector != Vector2.ZERO:
		var nueva := _direccion_dominante(vector)
		if nueva != direccion:
			direccion = nueva
			queue_redraw()


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
