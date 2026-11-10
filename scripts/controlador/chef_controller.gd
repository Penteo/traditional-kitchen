class_name ChefController
extends Node
## Mueve a los chefs en cada ciclo de fisica. Orden de resolucion: J1 y luego J2.

var chefs: Array[Chef] = []


func _ready() -> void:
	for nodo in get_tree().get_nodes_in_group("chefs"):
		chefs.append(nodo as Chef)
	chefs.sort_custom(func(a: Chef, b: Chef) -> bool: return a.numero_jugador < b.numero_jugador)


func _physics_process(_delta: float) -> void:
	for chef in chefs:
		chef.mover(InputController.obtener_vector(chef.numero_jugador))
