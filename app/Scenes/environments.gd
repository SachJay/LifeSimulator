extends Area2D

var nutrientValue = 6

func _ready():
	pass

func _on_Node2D_area_entered(area):
	if "food" in area.name:
		area.maxPlantsNearBy = nutrientValue
