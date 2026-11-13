class_name DecoradoNivel
extends RefCounted
## Viste un nivel con arte: baldosas en el suelo, ladrillo en el borde y mantel en los mostradores.
## Solo anade nodos de dibujo y oculta los ColorRect provisionales; no toca colisiones ni logica.
## Si falta alguna textura, ese elemento se queda con su color provisional.

const CARPETA_ARTE: String = "res://assets/art/escenario/"
const TEMAS: Array[String] = ["enrico", "jlb"]
const GROSOR_PARED: float = 40.0


static func aplicar(nivel_escena: Node2D, numero: int) -> void:
	var tema: String = TEMAS[clampi(numero - 1, 0, TEMAS.size() - 1)]
	var suelo := nivel_escena.get_node_or_null("Suelo") as ColorRect
	if suelo != null:
		_vestir(suelo, CARPETA_ARTE + "suelo_%s.png" % tema, true)
		_poner_paredes(suelo, CARPETA_ARTE + "pared_%s.png" % tema)
	for nombre in ["Mostrador1", "Mostrador2"]:
		var forma := nivel_escena.get_node_or_null("%s/Forma" % nombre) as ColorRect
		if forma != null:
			var lado := int(forma.offset_right - forma.offset_left)
			_vestir(forma, CARPETA_ARTE + "mostrador_%d.png" % lado, false)


## Pone una textura encima de un ColorRect (en mosaico o estirada) y oculta el color provisional.
static func _vestir(rect: ColorRect, ruta: String, en_mosaico: bool) -> TextureRect:
	if not ResourceLoader.exists(ruta):
		return null
	var textura := _crear_textura(ruta, en_mosaico)
	textura.position = Vector2(rect.offset_left, rect.offset_top)
	textura.size = Vector2(rect.offset_right - rect.offset_left, rect.offset_bottom - rect.offset_top)
	var padre := rect.get_parent()
	padre.add_child(textura)
	padre.move_child(textura, rect.get_index() + 1)
	rect.visible = false
	return textura


## Cuatro franjas de ladrillo alrededor del suelo, justo donde estan los muros invisibles.
static func _poner_paredes(suelo: ColorRect, ruta: String) -> void:
	if not ResourceLoader.exists(ruta):
		return
	var izquierda := suelo.offset_left
	var arriba := suelo.offset_top
	var derecha := suelo.offset_right
	var abajo := suelo.offset_bottom
	var ancho_total := derecha - izquierda + 2.0 * GROSOR_PARED
	var alto := abajo - arriba
	var franjas: Array[Rect2] = [
		Rect2(izquierda - GROSOR_PARED, arriba - GROSOR_PARED, ancho_total, GROSOR_PARED),
		Rect2(izquierda - GROSOR_PARED, abajo, ancho_total, GROSOR_PARED),
		Rect2(izquierda - GROSOR_PARED, arriba, GROSOR_PARED, alto),
		Rect2(derecha, arriba, GROSOR_PARED, alto),
	]
	var padre := suelo.get_parent()
	var posicion := suelo.get_index() + 1
	for franja in franjas:
		var textura := _crear_textura(ruta, true)
		textura.position = franja.position
		textura.size = franja.size
		padre.add_child(textura)
		padre.move_child(textura, posicion)
		posicion += 1


static func _crear_textura(ruta: String, en_mosaico: bool) -> TextureRect:
	var textura := TextureRect.new()
	textura.texture = load(ruta) as Texture2D
	textura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	textura.stretch_mode = TextureRect.STRETCH_TILE if en_mosaico else TextureRect.STRETCH_SCALE
	textura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return textura
