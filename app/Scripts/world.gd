extends Node

onready var totalAnimal = $CanvasLayer2/TotalAnimal
onready var timeElapsedLabel = $CanvasLayer2/TimeElapsedLabel
onready var averageSpeedLabel = $CanvasLayer2/AverageSpeedLabel
onready var averageSenseLabel = $CanvasLayer2/AverageSenseLabel

var rng = RandomNumberGenerator.new()

var counter = 0
var cameraX = ProjectSettings.get_setting("display/window/size/width")
var cameraY = ProjectSettings.get_setting("display/window/size/height")
var offset = 10

#Animal Variables
var animalSpeed = 500

var numOfAnimals = 1
var averageSpeed = 2000
var averageSense = 50

func _ready():
	totalAnimal.text = "# of Animal: " + str(numOfAnimals)

func _on_Timer_timeout():
	counter+=1

	if counter % 1 == 0:  
		var food = load("res://Scenes/food.tscn").instance()
		food.position.x = rng.randf_range(offset, cameraX-offset)
		food.position.y = rng.randf_range(offset, cameraY-offset)
		self.get_node("foodGroup").add_child(food)
		timeElapsedLabel.text = "Time Elapsed: " + str(counter)

	if counter % 25 == 0:
		pass #end of day

func whenAnimalCreated(animal):
	averageSpeed = (averageSpeed * numOfAnimals + animal.speed) / (numOfAnimals + 1)
	averageSense = (averageSense * numOfAnimals + animal.senseRad) / (numOfAnimals + 1)
	numOfAnimals += 1
	averageSpeedLabel.text = "Average Speed: " + str(int(averageSpeed))
	averageSenseLabel.text = "Average Sense: " + str(int(averageSense))
	totalAnimal.text = "# of Animals: " + str(numOfAnimals)

func whenAnimalDied(animal):
	averageSpeed = (averageSpeed * numOfAnimals - animal.speed) / (numOfAnimals - 1)
	averageSense = (averageSense * numOfAnimals - animal.senseRad) / (numOfAnimals - 1)
	numOfAnimals -= 1
	averageSpeedLabel.text = "Average Speed: " + str(int(averageSpeed))
	averageSenseLabel.text = "Average Sense: " + str(int(averageSense))
	totalAnimal.text = "# of Animals: " + str(numOfAnimals)

func _on_LineEdit_text_entered(new_text):
	if int(new_text) >= 1:
		animalSpeed = int(new_text)
	else:
		animalSpeed = 500
