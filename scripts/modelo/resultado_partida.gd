class_name ResultadoPartida
extends RefCounted
## Resumen de una partida para la pantalla de resultados.

var nivel: Nivel
var puntaje: int = 0
var cuota: int = 0
var estrellas: int = 0
var cuota_cumplida: bool = false
var entregados: int = 0
var vencidos: int = 0
var rechazados: int = 0
var quemados: int = 0
## Provisional: plato con mas entregas en este nivel; en empate gana el que llego primero a ese maximo.
var plato_mas_entregado: String = ""
## Entradas del Codice desbloqueadas en esta partida ("Nueva entrada desbloqueada").
var entradas_nuevas: Array[EntradaCodice] = []
## Dato curioso del plato mas entregado. Solo se rellena si no hay entradas nuevas.
var dato_curioso: String = ""

var _por_receta: Dictionary = {}


func registrar_entrega(receta: Receta) -> void:
	entregados += 1
	_por_receta[receta.nombre] = int(_por_receta.get(receta.nombre, 0)) + 1
	var actual := int(_por_receta.get(plato_mas_entregado, 0))
	if int(_por_receta[receta.nombre]) > actual:
		plato_mas_entregado = receta.nombre
