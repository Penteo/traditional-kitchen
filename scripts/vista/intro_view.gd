class_name IntroView
extends Pantalla
## Intro cinematica en 3D (tiempo real, hecha solo con formas primitivas).
## Emite `terminada` cuando acaba o cuando el jugador la salta.
##
## Mas adelante, para usar modelos reales, reemplaza el contenido de
## _construir_cocina() por una escena importada (.glb) y deja el resto igual.

signal terminada

const DURACION := 11.0           # duracion total en segundos
const FADE_ENTRADA := 1.0
const FADE_SALIDA := 1.2
const DURACION_CAMARA := 8.0     # tiempo que tarda la camara en llegar al plano final
const INICIO_TITULO := 5.2

const CAMARA_INICIO := Vector3(4.2, 2.6, 6.0)
const MIRA_INICIO := Vector3(0.0, 1.0, 0.0)
const CAMARA_FIN := Vector3(0.7, 1.25, 3.3)
const MIRA_FIN := Vector3(0.0, 0.25, 0.0)
const TAPA_Y := 0.82

var _mundo: Node3D
var _camara: Camera3D
var _tapa: Node3D
var _vapor: CPUParticles3D
var _fuego: OmniLight3D
var _velo: ColorRect
var _titulo: Label
var _subtitulo: Label
var _pista: Label
var _tween_principal: Tween
var _tiempo := 0.0
var _saltando := false
var _terminada := false


## Pantalla._ready() fija tema y anclas y luego llama a _construir().
func _construir() -> void:
	_mundo = Node3D.new()
	_mundo.name = "Mundo3D"
	add_child(_mundo)
	_construir_ambiente()
	_construir_cocina()
	_construir_vapor()
	_construir_camara()
	_construir_interfaz()
	_iniciar_secuencia()


func _process(delta: float) -> void:
	_tiempo += delta
	var avance := clampf(_tiempo / DURACION_CAMARA, 0.0, 1.0)
	var suave := smoothstep(0.0, 1.0, avance)
	var deriva := Vector3(sin(_tiempo * 0.5) * 0.06, sin(_tiempo * 0.7) * 0.03, 0.0)
	_camara.position = CAMARA_INICIO.lerp(CAMARA_FIN, suave) + deriva
	_camara.look_at(MIRA_INICIO.lerp(MIRA_FIN, suave))
	# La tapa de la olla vibra por el vapor y el fuego parpadea.
	_tapa.position.y = TAPA_Y + 0.012 * absf(sin(_tiempo * 9.0))
	_tapa.rotation_degrees.z = 1.5 * sin(_tiempo * 6.0)
	_fuego.light_energy = 1.1 + 0.3 * sin(_tiempo * 14.0) * sin(_tiempo * 5.3) + randf_range(-0.06, 0.06)


func _input(evento: InputEvent) -> void:
	if _terminada or _saltando:
		return
	var salto := false
	if evento is InputEventKey:
		var tecla := evento as InputEventKey
		salto = tecla.pressed and not tecla.echo
	elif evento is InputEventMouseButton:
		salto = (evento as InputEventMouseButton).pressed
	elif evento is InputEventJoypadButton:
		salto = (evento as InputEventJoypadButton).pressed
	if salto:
		get_viewport().set_input_as_handled()
		_saltar()


# ---------------------------------------------------------------------------
# Secuencia
# ---------------------------------------------------------------------------

func _iniciar_secuencia() -> void:
	_velo.color.a = 1.0
	_tween_principal = create_tween()
	_tween_principal.tween_property(_velo, "color:a", 0.0, FADE_ENTRADA)
	_tween_principal.tween_interval(DURACION - FADE_ENTRADA - FADE_SALIDA)
	_tween_principal.tween_property(_velo, "color:a", 1.0, FADE_SALIDA)
	_tween_principal.tween_callback(_finalizar)

	var textos := create_tween()
	textos.tween_interval(INICIO_TITULO)
	textos.tween_property(_titulo, "modulate:a", 1.0, 1.4)
	textos.tween_interval(0.3)
	textos.tween_property(_subtitulo, "modulate:a", 1.0, 1.0)

	var pista := create_tween()
	pista.tween_interval(1.5)
	pista.tween_property(_pista, "modulate:a", 0.65, 0.8)


func _saltar() -> void:
	_saltando = true
	if _tween_principal != null:
		_tween_principal.kill()
	var salida := create_tween()
	salida.tween_property(_velo, "color:a", 1.0, 0.3)
	salida.tween_callback(_finalizar)


func _finalizar() -> void:
	if _terminada:
		return
	_terminada = true
	terminada.emit()


# ---------------------------------------------------------------------------
# Construccion de la escena 3D
# ---------------------------------------------------------------------------

func _construir_ambiente() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.035, 0.03)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.82, 0.65)
	env.ambient_light_energy = 0.3
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var entorno := WorldEnvironment.new()
	entorno.environment = env
	_mundo.add_child(entorno)

	var sol := DirectionalLight3D.new()
	sol.rotation_degrees = Vector3(-52.0, 28.0, 0.0)
	sol.light_color = Color(1.0, 0.9, 0.75)
	sol.light_energy = 0.7
	sol.shadow_enabled = true
	_mundo.add_child(sol)

	_fuego = OmniLight3D.new()
	_fuego.position = Vector3(0.0, 0.55, 1.1)
	_fuego.light_color = Color(1.0, 0.55, 0.2)
	_fuego.light_energy = 1.1
	_fuego.omni_range = 6.0
	_mundo.add_child(_fuego)


func _construir_cocina() -> void:
	var madera := _mat(Color(0.36, 0.21, 0.11), 0.0, 0.8)
	var madera_clara := _mat(Color(0.72, 0.52, 0.3), 0.0, 0.7)
	var pared := _mat(Color(0.5, 0.3, 0.2), 0.0, 0.95)
	var piso := _mat(Color(0.12, 0.09, 0.08), 0.0, 1.0)
	var metal := _mat(Color(0.62, 0.62, 0.66), 0.85, 0.32)
	var hierro := _mat(Color(0.08, 0.08, 0.09), 0.5, 0.5)
	var barro := _mat(Color(0.74, 0.38, 0.22), 0.0, 0.9)

	# Mesa, patas, pared y piso
	_pieza(_caja(Vector3(7.0, 0.3, 3.0)), madera, Vector3(0.0, -0.15, 0.0))
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			_pieza(_caja(Vector3(0.25, 1.7, 0.25)), madera, Vector3(3.2 * sx, -1.15, 1.2 * sz))
	_pieza(_caja(Vector3(14.0, 8.0, 0.2)), pared, Vector3(0.0, 1.0, -1.9))
	_pieza(_caja(Vector3(16.0, 0.1, 10.0)), piso, Vector3(0.0, -2.05, 0.0))

	# Hornilla y olla
	_pieza(_cilindro(0.75, 0.75, 0.12), hierro, Vector3(0.0, 0.06, 0.0))
	_pieza(_cilindro(0.55, 0.5, 0.7), metal, Vector3(0.0, 0.47, 0.0))
	for lado: float in [-1.0, 1.0]:
		_pieza(_caja(Vector3(0.2, 0.08, 0.1)), hierro, Vector3(0.62 * lado, 0.65, 0.0))
	_tapa = Node3D.new()
	_tapa.position = Vector3(0.0, TAPA_Y, 0.0)
	_mundo.add_child(_tapa)
	_pieza(_cilindro(0.58, 0.58, 0.08), metal, Vector3(0.0, 0.04, 0.0), Vector3.ZERO, _tapa)
	_pieza(_esfera(0.07), hierro, Vector3(0.0, 0.12, 0.0), Vector3.ZERO, _tapa)

	# Tabla de cortar con ingredientes
	var tabla := Node3D.new()
	tabla.position = Vector3(-1.9, 0.0, 0.6)
	tabla.rotation_degrees = Vector3(0.0, 14.0, 0.0)
	_mundo.add_child(tabla)
	_pieza(_caja(Vector3(1.4, 0.06, 0.9)), madera_clara, Vector3(0.0, 0.03, 0.0), Vector3.ZERO, tabla)
	_pieza(_esfera(0.22), _mat(Color(0.8, 0.08, 0.06), 0.0, 0.4), Vector3(-0.35, 0.28, 0.0), Vector3.ZERO, tabla)
	_pieza(_esfera(0.2), _mat(Color(0.82, 0.7, 0.78), 0.0, 0.5), Vector3(0.0, 0.26, -0.15), Vector3.ZERO, tabla)
	_pieza(_cilindro(0.06, 0.0, 0.5), _mat(Color(0.95, 0.45, 0.08), 0.0, 0.6), Vector3(0.4, 0.09, 0.2), Vector3(0.0, 20.0, 90.0), tabla)
	_pieza(_caja(Vector3(0.55, 0.012, 0.1)), metal, Vector3(0.25, 0.066, -0.3), Vector3.ZERO, tabla)
	_pieza(_caja(Vector3(0.22, 0.04, 0.09)), hierro, Vector3(-0.18, 0.08, -0.3), Vector3.ZERO, tabla)

	# Cuenco de barro con limas
	_pieza(_cilindro(0.42, 0.26, 0.26), barro, Vector3(2.0, 0.13, 0.7))
	var lima := _mat(Color(0.45, 0.72, 0.15), 0.0, 0.5)
	for pos: Vector3 in [Vector3(1.88, 0.3, 0.62), Vector3(2.12, 0.3, 0.8), Vector3(2.0, 0.42, 0.7)]:
		_pieza(_esfera(0.13), lima, pos)

	# Estante con frascos
	_pieza(_caja(Vector3(4.4, 0.1, 0.5)), madera, Vector3(0.0, 1.9, -1.62))
	var colores_frasco: Array[Color] = [
		Color(0.8, 0.2, 0.1), Color(0.9, 0.7, 0.2), Color(0.3, 0.55, 0.25), Color(0.85, 0.85, 0.8),
	]
	for i in colores_frasco.size():
		var alto := 0.35 + 0.06 * i
		_pieza(_cilindro(0.14, 0.14, alto), _mat(colores_frasco[i], 0.0, 0.6), Vector3(-1.5 + i * 1.0, 1.95 + alto / 2.0, -1.62))


func _construir_vapor() -> void:
	var mat_vapor := StandardMaterial3D.new()
	mat_vapor.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_vapor.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_vapor.vertex_color_use_as_albedo = true
	mat_vapor.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	var bola := _esfera(0.12)
	bola.material = mat_vapor

	var degradado := Gradient.new()
	degradado.set_color(0, Color(1.0, 1.0, 1.0, 0.0))
	degradado.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	degradado.add_point(0.25, Color(1.0, 1.0, 1.0, 0.28))

	var crecer := Curve.new()
	crecer.add_point(Vector2(0.0, 0.5))
	crecer.add_point(Vector2(1.0, 2.2))

	_vapor = CPUParticles3D.new()
	_vapor.position = Vector3(0.0, TAPA_Y + 0.1, 0.0)
	_vapor.amount = 40
	_vapor.lifetime = 3.4
	_vapor.preprocess = 3.4
	_vapor.mesh = bola
	_vapor.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	_vapor.emission_sphere_radius = 0.3
	_vapor.direction = Vector3.UP
	_vapor.spread = 12.0
	_vapor.gravity = Vector3(0.0, 0.2, 0.0)
	_vapor.initial_velocity_min = 0.35
	_vapor.initial_velocity_max = 0.6
	_vapor.scale_amount_curve = crecer
	_vapor.color_ramp = degradado
	_mundo.add_child(_vapor)


func _construir_camara() -> void:
	_camara = Camera3D.new()
	_camara.fov = 55.0
	_camara.position = CAMARA_INICIO
	_mundo.add_child(_camara)
	_camara.current = true
	_camara.look_at(MIRA_INICIO)


func _construir_interfaz() -> void:
	_titulo = _crear_texto("TRADITIONAL KITCHEN", 118, 0.67, 0.82)
	_subtitulo = _crear_texto("Cocina cooperativa para dos", 44, 0.81, 0.89)
	_pista = _crear_texto("Pulsa cualquier tecla para saltar", 26, 0.92, 0.98)
	_pista.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_pista.offset_right = -40.0

	_velo = ColorRect.new()
	_velo.color = Color(0.0, 0.0, 0.0, 1.0)
	_velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_velo)
	_velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _crear_texto(texto: String, tam: int, ancla_arriba: float, ancla_abajo: float) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ajustes := LabelSettings.new()
	ajustes.font_size = tam
	ajustes.font_color = Color(1.0, 0.93, 0.8)
	ajustes.outline_size = maxi(4, int(tam * 0.1))
	ajustes.outline_color = Color(0.12, 0.05, 0.02)
	ajustes.shadow_size = 4
	ajustes.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	etiqueta.label_settings = ajustes
	etiqueta.modulate.a = 0.0
	add_child(etiqueta)
	etiqueta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	etiqueta.set_anchor(SIDE_TOP, ancla_arriba, true, false)
	etiqueta.set_anchor(SIDE_BOTTOM, ancla_abajo, true, false)
	return etiqueta


# ---------------------------------------------------------------------------
# Utilidades para armar primitivas
# ---------------------------------------------------------------------------

func _mat(color: Color, metalico := 0.0, rugosidad := 0.85) -> StandardMaterial3D:
	var resultado := StandardMaterial3D.new()
	resultado.albedo_color = color
	resultado.metallic = metalico
	resultado.roughness = rugosidad
	return resultado


func _caja(tam: Vector3) -> BoxMesh:
	var malla := BoxMesh.new()
	malla.size = tam
	return malla


func _cilindro(radio_sup: float, radio_inf: float, alto: float) -> CylinderMesh:
	var malla := CylinderMesh.new()
	malla.top_radius = radio_sup
	malla.bottom_radius = radio_inf
	malla.height = alto
	malla.radial_segments = 48
	return malla


func _esfera(radio: float) -> SphereMesh:
	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio * 2.0
	return malla


func _pieza(malla: Mesh, mat: Material, pos: Vector3, rot := Vector3.ZERO, padre: Node3D = null) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	instancia.material_override = mat
	instancia.position = pos
	instancia.rotation_degrees = rot
	var destino: Node3D = padre if padre != null else _mundo
	destino.add_child(instancia)
	return instancia
