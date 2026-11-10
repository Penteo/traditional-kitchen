class_name Puntuacion
extends RefCounted
## Puntaje compartido (Tabla 19). Unidad unica: puntos. Nunca baja de 0. Redondeo por evento, .5 hacia arriba.

signal puntaje_cambiado(puntos: int, cambio: int)

const FACTOR_PROPINA: float = 0.5
const PENALIZACION_VENCIDO: float = 0.5
const PENALIZACION_RECHAZO: float = 0.25
## Umbrales de estrellas como multiplo de la cuota por 10 (1,4 y 1,8), en enteros para evitar errores de coma flotante.
const UMBRAL_DOS_ESTRELLAS_X10: int = 14
const UMBRAL_TRES_ESTRELLAS_X10: int = 18

var puntos: int = 0


func reiniciar() -> void:
	puntos = 0
	puntaje_cambiado.emit(puntos, 0)


## Propina proporcional al tiempo restante, acotada entre 0 y 1 vez la base.
func propina(base: int, restante: float, limite: float) -> float:
	var valor := FACTOR_PROPINA * base * (restante / limite)
	return clampf(valor, 0.0, float(base))


func registrar_entrega(pedido: Pedido) -> int:
	var base := pedido.receta.valor_base
	var cambio := redondear(base + propina(base, pedido.tiempo_restante, pedido.receta.limite_tiempo))
	_aplicar(cambio)
	return cambio


func registrar_vencido(pedido: Pedido) -> int:
	var cambio := redondear(-PENALIZACION_VENCIDO * pedido.receta.valor_base)
	_aplicar(cambio)
	return cambio


func registrar_rechazo(pedido: Pedido) -> int:
	var cambio := redondear(-PENALIZACION_RECHAZO * pedido.receta.valor_base)
	_aplicar(cambio)
	return cambio


## 0 estrellas por debajo de la cuota; 1 con la cuota; 2 con 1,4 veces; 3 con 1,8 veces.
func estrellas(cuota: int) -> int:
	if puntos < cuota:
		return 0
	if puntos * 10 >= cuota * UMBRAL_TRES_ESTRELLAS_X10:
		return 3
	if puntos * 10 >= cuota * UMBRAL_DOS_ESTRELLAS_X10:
		return 2
	return 1


## .5 hacia arriba (hacia el valor mayor): 12.5 pasa a 13 y -12.5 pasa a -12.
static func redondear(valor: float) -> int:
	return int(floor(valor + 0.5))


func _aplicar(cambio: int) -> void:
	puntos = maxi(0, puntos + cambio)
	puntaje_cambiado.emit(puntos, cambio)
