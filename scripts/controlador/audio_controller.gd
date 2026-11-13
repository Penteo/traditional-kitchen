extends Node
## Reproduce efectos y pistas, y ajusta el volumen por bus. Autoload (sin class_name).
## Si falta un archivo de audio, lo ignora: los sonidos llegan despues, sin tocar el codigo.

const BUS_MUSICA: String = "Musica"
const BUS_SFX: String = "SFX"
const RUTA_SFX: String = "res://assets/audio/sfx/"
const RUTA_MUSICA: String = "res://assets/audio/musica/"
const EXTENSIONES: Array[String] = [".ogg", ".wav", ".mp3"]
const REPRODUCTORES_SFX: int = 8

## Los 10 efectos de la Tabla 23 y las 2 pistas.
const SFX: Array[String] = [
	"picar", "tomar_soltar", "accion_invalida", "estacion_lista", "peligro_quemado",
	"quemado", "pedido_nuevo", "entrega_aceptada", "rechazo_vencimiento", "boton_menu",
]
const PISTAS: Array[String] = ["menu", "partida"]

var _reproductores_sfx: Array[AudioStreamPlayer] = []
var _reproductor_musica: AudioStreamPlayer
var _cache: Dictionary = {}


func _ready() -> void:
	for i in REPRODUCTORES_SFX:
		var reproductor := AudioStreamPlayer.new()
		reproductor.bus = BUS_SFX
		add_child(reproductor)
		_reproductores_sfx.append(reproductor)
	_reproductor_musica = AudioStreamPlayer.new()
	_reproductor_musica.bus = BUS_MUSICA
	add_child(_reproductor_musica)
	EventBus.sfx_solicitado.connect(reproducir_sfx)


func reproducir_sfx(id: String) -> void:
	var flujo := _buscar(RUTA_SFX + id)
	if flujo == null:
		return
	for reproductor in _reproductores_sfx:
		if not reproductor.playing:
			reproductor.stream = flujo
			reproductor.play()
			return


func reproducir_pista(nombre: String) -> void:
	var flujo := _buscar(RUTA_MUSICA + nombre)
	if flujo == null:
		return
	if _reproductor_musica.stream == flujo and _reproductor_musica.playing:
		return
	_reproductor_musica.stream = flujo
	_reproductor_musica.play()


func detener_pista() -> void:
	_reproductor_musica.stop()


## valor entre 0 y 1. Con 0 el bus queda silenciado.
func ajustar_volumen(bus: String, valor: float) -> void:
	var indice := AudioServer.get_bus_index(bus)
	if indice < 0:
		return
	var lineal := clampf(valor, 0.0, 1.0)
	AudioServer.set_bus_mute(indice, lineal <= 0.0)
	if lineal > 0.0:
		AudioServer.set_bus_volume_db(indice, linear_to_db(lineal))


func obtener_volumen(bus: String) -> float:
	var indice := AudioServer.get_bus_index(bus)
	if indice < 0 or AudioServer.is_bus_mute(indice):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(indice))


func _buscar(ruta_base: String) -> AudioStream:
	if _cache.has(ruta_base):
		return _cache[ruta_base]
	var flujo: AudioStream = null
	for extension in EXTENSIONES:
		if ResourceLoader.exists(ruta_base + extension):
			flujo = load(ruta_base + extension) as AudioStream
			break
	_cache[ruta_base] = flujo
	return flujo
