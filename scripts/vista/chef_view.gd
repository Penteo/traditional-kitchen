class_name ChefView
extends Node2D
## Vista del chef. Elige una de las tres animaciones (reposo, caminar, cargar item) y dibuja un placeholder.
## Cuando llegue el arte final, un AnimatedSprite2D con esas tres animaciones reemplaza el dibujo.

signal animacion_cambiada(animacion: Animacion)

enum Animacion { REPOSO, CAMINAR, CARGAR }

const NOMBRES: Array[String] = ["reposo", "caminar", "cargar"]
const VELOCIDAD_MINIMA: float = 1.0
const DURACION_PARPADEO: float = 0.45

var animacion: Animacion = Animacion.REPOSO

var _chef: Chef = null
var _tiempo: float = 0.0
var _parpadeo: float = 0.0
var _direccion_dibujada: Chef.Direccion = Chef.Direccion.ABAJO


func _ready() -> void:
	_chef = get_parent() as Chef
	_chef.accion_invalida.connect(_al_accion_invalida)
	_chef.item_cambiado.connect(queue_redraw)
	queue_redraw()


func _process(delta: float) -> void:
	var nueva := _elegir_animacion()
	if nueva != animacion:
		animacion = nueva
		animacion_cambiada.emit(nueva)
		queue_redraw()
	if _se_mueve() or _parpadeo > 0.0:
		_tiempo += delta
		queue_redraw()
	if _parpadeo > 0.0:
		_parpadeo = maxf(0.0, _parpadeo - delta)
		if _parpadeo == 0.0:
			queue_redraw()
	if _chef.direccion != _direccion_dibujada:
		_direccion_dibujada = _chef.direccion
		queue_redraw()


func nombre_animacion() -> String:
	return NOMBRES[animacion]


func _elegir_animacion() -> Animacion:
	if _chef.item_en_mano != null:
		return Animacion.CARGAR
	if _se_mueve():
		return Animacion.CAMINAR
	return Animacion.REPOSO


func _se_mueve() -> bool:
	return _chef.velocity.length() > VELOCIDAD_MINIMA


func _al_accion_invalida() -> void:
	_parpadeo = DURACION_PARPADEO
	queue_redraw()


## El icono del item parpadea durante una accion invalida.
func _icono_visible() -> bool:
	return _parpadeo <= 0.0 or int(_tiempo * 14.0) % 2 == 0


# Dibujo provisional hasta tener el arte final.
func _draw() -> void:
	if _chef == null:
		return
	var radio := _chef.parametros.radio_colision
	var escala := 1.0
	if _se_mueve():
		escala = 1.0 + 0.06 * sin(_tiempo * 16.0)
	draw_circle(Vector2.ZERO, radio * escala, _chef.color)
	draw_line(Vector2.ZERO, _chef.vector_direccion() * radio, Color.WHITE, 4.0)
	if animacion == Animacion.CARGAR:
		var brazo := _chef.color.lightened(0.3)
		draw_circle(Vector2(-radio, -radio * 0.2), 10.0, brazo)
		draw_circle(Vector2(radio, -radio * 0.2), 10.0, brazo)
	var item := _chef.item_en_mano
	if item != null and _icono_visible():
		var posicion := Vector2(0.0, -radio - 24.0)
		draw_circle(posicion, 16.0, item.color())
		draw_string(ThemeDB.fallback_font, posicion + Vector2(-60.0, -24.0), item.etiqueta(), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 20)
