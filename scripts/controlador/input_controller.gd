extends Node
## Lee las entradas de cada jugador. J1 y J2 usan teclas distintas, sin compartir.

const ACCIONES := {
	1: {"arriba": "j1_arriba", "abajo": "j1_abajo", "izquierda": "j1_izquierda", "derecha": "j1_derecha"},
	2: {"arriba": "j2_arriba", "abajo": "j2_abajo", "izquierda": "j2_izquierda", "derecha": "j2_derecha"},
}


## Devuelve el vector de movimiento del jugador (longitud maxima 1, la diagonal ya viene normalizada).
func obtener_vector(numero_jugador: int) -> Vector2:
	var a: Dictionary = ACCIONES[numero_jugador]
	return Input.get_vector(a["izquierda"], a["derecha"], a["arriba"], a["abajo"])
