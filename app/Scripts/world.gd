extends Node

onready var label = $CanvasLayer2/Label

var numOfAnimals = 8

var rng = RandomNumberGenerator.new()

var counter = 0
var cameraX = ProjectSettings.get_setting("display/window/size/width")
var cameraY = ProjectSettings.get_setting("display/window/size/height")
var offset = 10

#Animal Variables
var animalSpeed = 500

func _ready():
	label.text = "# of Animal: " + str(numOfAnimals)
	
func _on_Timer_timeout():
	counter+=1
	
	if counter % 1 == 0:  
		var food = load("res://Scenes/food.tscn").instance()
		food.position.x = rng.randf_range(offset, cameraX-offset)
		food.position.y = rng.randf_range(offset, cameraY-offset)
		self.get_node("foodGroup").add_child(food)

	if counter % 25 == 0:  
		#end of day
		counter = 0

func whenAnimalCreated():
	numOfAnimals += 1
	label.text = "# of Animals: " + str(numOfAnimals)
	
func whenAnimalDied():
	numOfAnimals -= 1
	label.text = "# of Animals: " + str(numOfAnimals)


func _on_LineEdit_text_entered(new_text):
	if int(new_text) >= 1:
		animalSpeed = int(new_text)
	else:
		animalSpeed = 500
