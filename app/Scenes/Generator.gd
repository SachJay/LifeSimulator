extends Node

onready var tween = $food
var rng = RandomNumberGenerator.new()

var counter = 0;

func _ready():
	pass


func _on_Timer_timeout():
	counter+=1
	
#	var child = load("res://Scenes/animal.tscn").instance()
#	self.add_child(child)
	
	if counter % 2 == 0:  
		var food = load("res://Scenes/food.tscn").instance()
		food.position.x = rng.randf_range(-450, 450)
		food.position.y = rng.randf_range(-250, 250)
		self.add_child(food)

	if counter % 25 == 0:  
		#end of day
		counter = 0
	
	print("1 sec has passed")
