class_name EntradaCodice
extends Resource
## Una entrada del Codice Culinario (maximo 60 palabras). Solo lectura durante la partida.

@export var id: String = ""
@export var receta: Receta
@export var nombre: String = ""
@export var origen: String = ""
@export var ingredientes: String = ""
@export var en_el_juego: String = ""
@export var dato_curioso: String = ""
## Fuente de los datos. Vacia mientras no se registre (ver docs/fuentes_codice.md).
@export var fuente: String = ""
@export var verificada: bool = false


func texto_completo() -> String:
	return "%s\nOrigen: %s\nIngredientes: %s\nEn el juego: %s\nDato curioso: %s" % [nombre, origen, ingredientes, en_el_juego, dato_curioso]


## Palabras del cuerpo de la entrada (sin contar las etiquetas). Debe ser 60 o menos.
func cantidad_palabras() -> int:
	var texto := " ".join(PackedStringArray([origen, ingredientes, en_el_juego, dato_curioso]))
	return texto.split(" ", false).size()
