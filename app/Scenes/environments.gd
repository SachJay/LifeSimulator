extends Area2D

var nutrientValue = 2

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var rand = rng.randf_range(3, 8)
	print(rand)
	nutrientValue = rand as int

func _on_Node2D_area_entered(area):
	if "food" in area.name:
		area.maxPlantsNearBy = nutrientValue
