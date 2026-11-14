extends Node
## Lee las entradas de cada jugador. J1 y J2 usan teclas distintas, sin compartir.

const ACCIONES := {
	1: {"arriba": "j1_arriba", "abajo": "j1_abajo", "izquierda": "j1_izquierda", "derecha": "j1_derecha", "interactuar": "j1_interactuar", "procesar": "j1_procesar"},
	2: {"arriba": "j2_arriba", "abajo": "j2_abajo", "izquierda": "j2_izquierda", "derecha": "j2_derecha", "interactuar": "j2_interactuar", "procesar": "j2_procesar"},
}


## Devuelve el vector de movimiento del jugador (longitud maxima 1, la diagonal ya viene normalizada).
func obtener_vector(numero_jugador: int) -> Vector2:
	var a: Dictionary = ACCIONES[numero_jugador]
	return Input.get_vector(a["izquierda"], a["derecha"], a["arriba"], a["abajo"])


## True solo en el ciclo en que se pulsa la tecla de Interactuar.
func interactuar_presionado(numero_jugador: int) -> bool:
	return Input.is_action_just_pressed(ACCIONES[numero_jugador]["interactuar"])


## True solo en el ciclo en que se pulsa la tecla de Procesar.
func procesar_presionado(numero_jugador: int) -> bool:
	return Input.is_action_just_pressed(ACCIONES[numero_jugador]["procesar"])


## Texto de la tecla que el jugador debe pulsar, segun SU distribucion de teclado.
## Las acciones usan posiciones fisicas: en un teclado latinoamericano la tecla de "/" muestra "-".
## accion: "arriba", "abajo", "izquierda", "derecha", "interactuar" o "procesar".
func texto_tecla(numero_jugador: int, accion: String) -> String:
	var nombre: String = ACCIONES[numero_jugador][accion]
	for evento in InputMap.action_get_events(nombre):
		if evento is InputEventKey:
			var codigo: Key = DisplayServer.keyboard_get_keycode_from_physical(evento.physical_keycode)
			return OS.get_keycode_string(codigo)
	return "?"
