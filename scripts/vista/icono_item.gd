class_name IconoItem
extends RefCounted
## Dibuja el icono de un item (ingrediente o plato) sobre cualquier nodo con _draw().
## Si falta el PNG, devuelve false y quien llama usa su dibujo provisional.

const CARPETA_ARTE: String = "res://assets/art/items/"

static var _cache: Dictionary = {}


static func hay_arte(item: Item) -> bool:
	if item is Ingrediente:
		return _textura_ingrediente(item as Ingrediente) != null
	if item is Plato:
		return _cargar("plato") != null
	return false


static func dibujar(lienzo: CanvasItem, item: Item, centro: Vector2, lado: float) -> bool:
	if item is Ingrediente:
		var textura := _textura_ingrediente(item as Ingrediente)
		if textura == null:
			return false
		lienzo.draw_texture_rect(textura, _caja(centro, lado), false)
		return true
	if item is Plato:
		return _dibujar_plato(lienzo, item as Plato, centro, lado)
	return false


## El plato vacio y, encima, hasta cuatro de sus ingredientes en miniatura.
static func _dibujar_plato(lienzo: CanvasItem, plato: Plato, centro: Vector2, lado: float) -> bool:
	var base := _cargar("plato")
	if base == null:
		return false
	lienzo.draw_texture_rect(base, _caja(centro, lado), false)
	var cantidad := mini(plato.componentes.size(), 4)
	for i in cantidad:
		var textura := _textura_ingrediente(plato.componentes[i])
		if textura != null:
			lienzo.draw_texture_rect(textura, _caja(centro + _desplazamiento(i, cantidad) * lado, lado * 0.5), false)
	return true


static func _desplazamiento(indice: int, cantidad: int) -> Vector2:
	match cantidad:
		1:
			return Vector2(0.0, 0.03)
		2:
			return Vector2(-0.19 if indice == 0 else 0.19, 0.05)
		3:
			return [Vector2(0.0, -0.08), Vector2(-0.2, 0.12), Vector2(0.2, 0.12)][indice]
	return [Vector2(-0.2, -0.04), Vector2(0.2, -0.04), Vector2(-0.2, 0.16), Vector2(0.2, 0.16)][indice]


static func _caja(centro: Vector2, lado: float) -> Rect2:
	return Rect2(centro - Vector2(lado, lado) / 2.0, Vector2(lado, lado))


static func _textura_ingrediente(ingrediente: Ingrediente) -> Texture2D:
	return _cargar("%s_%s" % [Ingrediente.NOMBRES[ingrediente.tipo], Ingrediente.ESTADOS[ingrediente.estado]])


static func _cargar(nombre: String) -> Texture2D:
	if _cache.has(nombre):
		return _cache[nombre] as Texture2D
	var ruta := "%s%s.png" % [CARPETA_ARTE, nombre]
	var textura: Texture2D = null
	if ResourceLoader.exists(ruta):
		textura = load(ruta) as Texture2D
	_cache[nombre] = textura
	return textura
