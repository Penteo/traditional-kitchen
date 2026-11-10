class_name ChefController
extends Node
## Mueve a los chefs y resuelve sus interacciones en cada ciclo de fisica. Orden: J1 y luego J2.

var chefs: Array[Chef] = []


func _ready() -> void:
	for nodo in get_tree().get_nodes_in_group("chefs"):
		chefs.append(nodo as Chef)
	chefs.sort_custom(func(a: Chef, b: Chef) -> bool: return a.numero_jugador < b.numero_jugador)


func _physics_process(_delta: float) -> void:
	var actuan: Array[Chef] = []
	for chef in chefs:
		chef.mover(InputController.obtener_vector(chef.numero_jugador))
		if InputController.interactuar_presionado(chef.numero_jugador):
			actuan.append(chef)
	resolver_interacciones(actuan)


## R3: si dos chefs actuan sobre la misma estacion en el mismo ciclo, prevalece J1 (viene primero).
func resolver_interacciones(actuan: Array[Chef]) -> void:
	var usadas: Array[Estacion] = []
	for chef in actuan:
		var estacion := chef.estacion_objetivo()
		if estacion == null or usadas.has(estacion):
			continue
		usadas.append(estacion)
		interactuar(chef, estacion)


## Tabla 14: depositar en estacion compatible, retirar o recoger de un surtidor. Lo incompatible no tiene efecto.
func interactuar(chef: Chef, estacion: Estacion) -> void:
	if chef.sostiene_item():
		if estacion.acepta(chef.item_en_mano):
			estacion.recibir(chef.soltar())
	elif estacion.puede_entregar():
		chef.tomar(estacion.retirar())
