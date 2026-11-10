class_name ChefController
extends Node
## Mueve a los chefs y resuelve sus acciones en cada ciclo de fisica. Orden: J1 y luego J2.

## Se emite al terminar las acciones de ambos chefs; el reloj de la partida avanza las estaciones despues.
signal ciclo_terminado(delta: float)

enum Accion { INTERACTUAR, PROCESAR }

var chefs: Array[Chef] = []


func _ready() -> void:
	for nodo in get_tree().get_nodes_in_group("chefs"):
		chefs.append(nodo as Chef)
	chefs.sort_custom(func(a: Chef, b: Chef) -> bool: return a.numero_jugador < b.numero_jugador)


func _physics_process(delta: float) -> void:
	var pedidos: Array[Dictionary] = []
	for chef in chefs:
		chef.mover(InputController.obtener_vector(chef.numero_jugador))
		if InputController.interactuar_presionado(chef.numero_jugador):
			pedidos.append({"chef": chef, "accion": Accion.INTERACTUAR})
		elif InputController.procesar_presionado(chef.numero_jugador):
			pedidos.append({"chef": chef, "accion": Accion.PROCESAR})
	resolver_acciones(pedidos)
	ciclo_terminado.emit(delta)


## R3: si dos chefs actuan sobre la misma estacion en el mismo ciclo, prevalece J1 (viene primero).
func resolver_acciones(pedidos: Array[Dictionary]) -> void:
	var usadas: Array[Estacion] = []
	for pedido in pedidos:
		var chef: Chef = pedido["chef"]
		var estacion := chef.estacion_objetivo()
		if estacion == null or usadas.has(estacion):
			continue
		usadas.append(estacion)
		match pedido["accion"]:
			Accion.INTERACTUAR:
				interactuar(chef, estacion)
			Accion.PROCESAR:
				estacion.procesar()


## Tabla 14: depositar en estacion compatible, retirar o recoger de un surtidor. Lo incompatible no tiene efecto.
func interactuar(chef: Chef, estacion: Estacion) -> void:
	if chef.sostiene_item():
		if estacion.acepta(chef.item_en_mano):
			estacion.recibir(chef.soltar())
	elif estacion.puede_entregar():
		chef.tomar(estacion.retirar())
