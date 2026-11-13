extends Node
## Guarda y carga el progreso en un archivo local tipo JSON. Autoload (sin class_name).

const RUTA_ARCHIVO: String = "user://progreso.json"


## Si el archivo falta o esta danado, devuelve un progreso vacio y el juego sigue sin cerrarse.
func cargar() -> ProgresoJugador:
	var progreso := ProgresoJugador.new()
	if not FileAccess.file_exists(RUTA_ARCHIVO):
		return progreso
	var archivo := FileAccess.open(RUTA_ARCHIVO, FileAccess.READ)
	if archivo == null:
		return progreso
	var json := JSON.new()
	if json.parse(archivo.get_as_text()) != OK:
		return progreso
	var datos: Variant = json.data
	if datos is Dictionary:
		progreso.desde_diccionario(datos)
	return progreso


func guardar(progreso: ProgresoJugador) -> bool:
	var archivo := FileAccess.open(RUTA_ARCHIVO, FileAccess.WRITE)
	if archivo == null:
		return false
	archivo.store_string(JSON.stringify(progreso.a_diccionario(), "\t"))
	return true
