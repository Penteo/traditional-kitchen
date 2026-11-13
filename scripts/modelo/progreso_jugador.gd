class_name ProgresoJugador
extends RefCounted
## Lo que se guarda entre sesiones: estrellas, mejor puntaje, nivel desbloqueado, Codice y volumenes.

const NIVELES_TOTALES: int = 2
const VERSION_ARCHIVO: int = 1

## Estrellas y mejor puntaje por nivel. La clave es el numero de nivel como texto ("1", "2").
var estrellas: Dictionary = {}
var mejor_puntaje: Dictionary = {}
var nivel_desbloqueado: int = 1
var entradas_codice: PackedStringArray = PackedStringArray()
var volumen_musica: float = 1.0
var volumen_sfx: float = 1.0


func estrellas_de(numero: int) -> int:
	return _a_entero(estrellas.get(str(numero), 0), 0)


func mejor_puntaje_de(numero: int) -> int:
	return _a_entero(mejor_puntaje.get(str(numero), 0), 0)


func esta_desbloqueado(numero: int) -> bool:
	return numero <= nivel_desbloqueado


## Repetir un nivel conserva el mejor puntaje y el mayor numero de estrellas. JLB se desbloquea con 1 estrella en Fermi.
func registrar_resultado(resultado: ResultadoPartida) -> void:
	var numero := resultado.nivel.numero
	var clave := str(numero)
	estrellas[clave] = maxi(estrellas_de(numero), resultado.estrellas)
	mejor_puntaje[clave] = maxi(mejor_puntaje_de(numero), resultado.puntaje)
	if resultado.estrellas >= 1 and numero >= nivel_desbloqueado:
		nivel_desbloqueado = mini(numero + 1, NIVELES_TOTALES)


func a_diccionario() -> Dictionary:
	return {
		"version": VERSION_ARCHIVO,
		"nivel_desbloqueado": nivel_desbloqueado,
		"estrellas": estrellas,
		"mejor_puntaje": mejor_puntaje,
		"entradas_codice": Array(entradas_codice),
		"volumen_musica": volumen_musica,
		"volumen_sfx": volumen_sfx,
	}


## Tolerante: cualquier dato que falte o tenga un tipo raro se ignora y queda el valor inicial.
func desde_diccionario(datos: Dictionary) -> void:
	nivel_desbloqueado = clampi(_a_entero(datos.get("nivel_desbloqueado", 1), 1), 1, NIVELES_TOTALES)
	estrellas = _por_nivel(datos.get("estrellas", {}), 3)
	mejor_puntaje = _por_nivel(datos.get("mejor_puntaje", {}), 1000000)
	entradas_codice = PackedStringArray()
	var lista: Variant = datos.get("entradas_codice", [])
	if lista is Array:
		for id in lista:
			if id is String and not entradas_codice.has(id):
				entradas_codice.append(id)
	volumen_musica = clampf(_a_decimal(datos.get("volumen_musica", 1.0), 1.0), 0.0, 1.0)
	volumen_sfx = clampf(_a_decimal(datos.get("volumen_sfx", 1.0), 1.0), 0.0, 1.0)


func _por_nivel(origen: Variant, maximo: int) -> Dictionary:
	var resultado := {}
	if origen is Dictionary:
		for numero in range(1, NIVELES_TOTALES + 1):
			var clave := str(numero)
			if origen.has(clave):
				resultado[clave] = clampi(_a_entero(origen[clave], 0), 0, maximo)
	return resultado


func _a_entero(valor: Variant, defecto: int) -> int:
	if valor is int or valor is float:
		return int(valor)
	return defecto


func _a_decimal(valor: Variant, defecto: float) -> float:
	if valor is int or valor is float:
		return float(valor)
	return defecto
