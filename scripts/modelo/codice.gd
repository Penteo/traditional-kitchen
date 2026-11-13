class_name Codice
extends RefCounted
## Enciclopedia del juego: una entrada por receta. Se desbloquea con la primera entrega aceptada.
## Los desbloqueos son "pendientes" durante el nivel y solo se confirman al terminarlo.

signal entrada_desbloqueada(entrada: EntradaCodice)

const RUTAS_ENTRADAS: Array[String] = [
	"res://data/codice/arepa_con_queso.tres",
	"res://data/codice/empanadas.tres",
	"res://data/codice/mute_santandereano.tres",
]
const TEXTO_BLOQUEADO: String = "???"

var entradas: Array[EntradaCodice] = []

var _desbloqueadas: PackedStringArray = PackedStringArray()
var _pendientes: PackedStringArray = PackedStringArray()


func cargar_entradas() -> void:
	entradas.clear()
	for ruta in RUTAS_ENTRADAS:
		var entrada := load(ruta) as EntradaCodice
		if entrada != null:
			entradas.append(entrada)


func cargar_desbloqueadas(ids: PackedStringArray) -> void:
	_desbloqueadas = ids.duplicate()
	_pendientes = PackedStringArray()


func entrada_de(receta: Receta) -> EntradaCodice:
	for entrada in entradas:
		if entrada.receta == receta:
			return entrada
	return null


func entrada_por_nombre(nombre: String) -> EntradaCodice:
	for entrada in entradas:
		if entrada.receta != null and entrada.receta.nombre == nombre:
			return entrada
	return null


func esta_desbloqueada(entrada: EntradaCodice) -> bool:
	return _desbloqueadas.has(entrada.id) or _pendientes.has(entrada.id)


## Las entradas bloqueadas se muestran como "???".
func nombre_visible(entrada: EntradaCodice) -> String:
	return entrada.nombre if esta_desbloqueada(entrada) else TEXTO_BLOQUEADO


## Solo la primera entrega aceptada de una receta desbloquea su entrada. Devuelve la entrada nueva, o null.
func desbloquear(receta: Receta) -> EntradaCodice:
	var entrada := entrada_de(receta)
	if entrada == null or esta_desbloqueada(entrada):
		return null
	_pendientes.append(entrada.id)
	entrada_desbloqueada.emit(entrada)
	return entrada


## Al terminar el nivel: los pendientes pasan a desbloqueadas.
func confirmar() -> void:
	for id in _pendientes:
		if not _desbloqueadas.has(id):
			_desbloqueadas.append(id)
	_pendientes = PackedStringArray()


## Al reiniciar o salir a mitad de nivel: se pierden los desbloqueos de esa partida.
func descartar_pendientes() -> void:
	_pendientes = PackedStringArray()


func ids_desbloqueadas() -> PackedStringArray:
	return _desbloqueadas.duplicate()


func cantidad_desbloqueadas() -> int:
	return _desbloqueadas.size()
