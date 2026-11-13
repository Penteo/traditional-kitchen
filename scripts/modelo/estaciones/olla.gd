class_name Olla
extends EstacionCoccion
## Cocina papa y carne picadas en dos ranuras exclusivas (25 s, ventana de 10 s). Produce un solo mute.


func _configurar() -> void:
	nombre = "Olla"
	color_placeholder = Color(0.35, 0.5, 0.6)
	tipos_aceptados = [Ingrediente.Tipo.PAPA, Ingrediente.Tipo.CARNE]
	estado_requerido = Ingrediente.Estado.PICADO
	items_para_iniciar = 2


func _resultado_cocido() -> Array[Item]:
	var resultado: Array[Item] = [Ingrediente.new(Ingrediente.Tipo.MUTE, Ingrediente.Estado.COCIDO)]
	return resultado
