class_name Nivel
extends Resource
## Datos de un nivel (Tablas 18 y 20 del GDD). Solo lectura durante la partida.

@export var numero: int = 1
@export var nombre: String = ""
@export var duracion: float = 180.0
@export var cuota: int = 250
@export var intervalo_pedidos: float = 25.0
@export var cupo_pedidos: int = 3
@export var primer_pedido: float = 5.0
@export var ventana_sin_pedidos: float = 30.0
## Secuencia fija de pedidos: cada elemento es una Receta.
@export var secuencia_pedidos: Array = []


func secuencia_tipada() -> Array[Receta]:
	var resultado: Array[Receta] = []
	for receta in secuencia_pedidos:
		resultado.append(receta as Receta)
	return resultado


## Recetas distintas del nivel, en orden de aparicion.
func recetas_disponibles() -> Array[Receta]:
	var resultado: Array[Receta] = []
	for receta in secuencia_tipada():
		if not resultado.has(receta):
			resultado.append(receta)
	return resultado


func suma_valores_base() -> int:
	var suma := 0
	for receta in secuencia_tipada():
		suma += receta.valor_base
	return suma
