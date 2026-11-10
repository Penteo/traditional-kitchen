class_name Pedido
extends RefCounted
## Un pedido de la secuencia del nivel. Termina como entregado, vencido o rechazado.

enum Estado { ACTIVO, ENTREGADO, VENCIDO, RECHAZADO }

var receta: Receta
var numero: int
var estado: Estado = Estado.ACTIVO
var tiempo_restante: float


func _init(p_receta: Receta = null, p_numero: int = 0) -> void:
	receta = p_receta
	numero = p_numero
	tiempo_restante = p_receta.limite_tiempo if p_receta != null else 0.0


## Avanza el tiempo. Devuelve true solo en el instante en que el pedido vence (una unica vez).
func actualizar(delta: float) -> bool:
	if estado != Estado.ACTIVO:
		return false
	tiempo_restante -= delta
	if tiempo_restante <= 0.0:
		tiempo_restante = 0.0
		estado = Estado.VENCIDO
		return true
	return false


## Fraccion de tiempo que queda (1.0 = recien llegado, 0.0 = vencido).
func fraccion_restante() -> float:
	return tiempo_restante / receta.limite_tiempo
