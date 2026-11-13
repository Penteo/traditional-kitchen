extends Node
## Guarda y carga el progreso en un archivo local tipo JSON. Autoload (sin class_name).

const RUTA_ARCHIVO: String = "user://progreso.json"
const RUTA_TEMPORAL: String = "user://progreso.json.tmp"


## Si el archivo falta o esta danado, devuelve un progreso vacio y el juego sigue sin cerrarse.
func cargar() -> ProgresoJugador:
	var progreso := ProgresoJugador.new()
	if not FileAccess.file_exists(RUTA_ARCHIVO):
		return progreso
	var archivo := FileAccess.open(RUTA_ARCHIVO, FileAccess.READ)
	if archivo == null:
		return progreso
	var json := JSON.new()
	var texto := archivo.get_as_text()
	archivo.close()
	if json.parse(texto) != OK:
		_respaldar_corrupto()
		return progreso
	var datos: Variant = json.data
	if datos is Dictionary:
		progreso.desde_diccionario(datos)
	return progreso


## Escribe primero en un archivo temporal y luego lo renombra, para que un cierre a mitad de la escritura
## no deje el progreso a medias. Si el renombrado falla, escribe directo como antes.
func guardar(progreso: ProgresoJugador) -> bool:
	var texto := JSON.stringify(progreso.a_diccionario(), "\t")
	if _escribir(RUTA_TEMPORAL, texto):
		if DirAccess.rename_absolute(RUTA_TEMPORAL, RUTA_ARCHIVO) == OK:
			return true
		DirAccess.remove_absolute(RUTA_TEMPORAL)
	var guardado := _escribir(RUTA_ARCHIVO, texto)
	if not guardado:
		push_warning("No se pudo guardar el progreso en " + RUTA_ARCHIVO)
	return guardado


func _escribir(ruta: String, texto: String) -> bool:
	var archivo := FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		return false
	archivo.store_string(texto)
	archivo.close()
	return true


## Conserva una copia del archivo danado para no perderlo cuando se guarde un progreso nuevo encima.
func _respaldar_corrupto() -> void:
	push_warning("progreso.json danado: se conserva una copia en " + RUTA_ARCHIVO + ".corrupto")
	DirAccess.copy_absolute(RUTA_ARCHIVO, RUTA_ARCHIVO + ".corrupto")
