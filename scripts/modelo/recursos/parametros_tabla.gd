class_name ParametrosTabla
extends Resource
## Tiempos de corte de la tabla (Tabla 15).

@export var tiempo_queso: float = 2.0
@export var tiempo_papa: float = 3.0
@export var tiempo_carne: float = 5.0


func tiempo_para(tipo: Ingrediente.Tipo) -> float:
	match tipo:
		Ingrediente.Tipo.QUESO:
			return tiempo_queso
		Ingrediente.Tipo.PAPA:
			return tiempo_papa
		Ingrediente.Tipo.CARNE:
			return tiempo_carne
	return 0.0
