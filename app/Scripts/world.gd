extends Node

onready var totalHerb = $CanvasLayer2/TotalHerb
onready var totalCarn = $CanvasLayer2/TotalCarn
onready var timeElapsedLabel = $CanvasLayer2/TimeElapsedLabel
onready var camera = $MainCamera
onready var traitDropdown = $CanvasLayer2/OptionButton
onready var leftWall = $left
onready var upWall = $up
onready var rightWall = $right
onready var downWall = $down
var rng = RandomNumberGenerator.new()

var counter = 0
var minX
var minY
var maxX
var maxY
var offset = 75

#Animal Variables
var animalSpeed = 500

var averageSpeed = 2000
var averageSense = 50

func _ready():
	totalHerb.text = "# of Herbs: " + str(get_tree().get_nodes_in_group("herb").size())
	totalCarn.text = "# of Carns: " + str(get_tree().get_nodes_in_group("carn").size())
	traitDropdown.add_item("Speed")
	traitDropdown.add_item("Sense")
	traitDropdown.add_item("All")
	get_tree().call_group("animals", "update_modulate", 0)
	minX = leftWall.position.x
	minY = upWall.position.y
	maxX = rightWall.position.x
	maxY = downWall.position.y
	print(str(maxX)+" "+str(maxY))

func _process(delta):
	camera.position.x += delta * (Input.get_action_strength("run_right") - Input.get_action_strength("run_left")) * 1000
	camera.position.y -= delta * (Input.get_action_strength("run_up") - Input.get_action_strength("run_down")) * 1000
	camera.zoom.x += delta * (Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out")) * 5
	camera.zoom.y += delta * (Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out")) * 5
	if(camera.zoom.x < 0.1):
		camera.zoom.x = 0.1
		
	if(camera.zoom.y < 0.1):
		camera.zoom.y = 0.1
		
func _on_Timer_timeout():
	counter+=1

	if counter % 1 == 0:  
		
		for n in range(1,20):
			var food = load("res://Scenes/food.tscn").instance()
			food.position.x = rng.randf_range(minX+offset, maxX-offset) 
			food.position.y = rng.randf_range(minY+offset, maxY-offset)
			self.get_node("foodGroup").add_child(food)
		timeElapsedLabel.text = "Time Elapsed: " + str(counter)

	if counter % 10 == 0:
		totalHerb.text = "# of Herbs: " + str(get_tree().get_nodes_in_group("herb").size())
		totalCarn.text = "# of Carns: " + str(get_tree().get_nodes_in_group("carn").size()/2)

func whenAnimalCreated(animal):
	pass
	#averageSpeed = (averageSpeed * numOfAnimals + animal.speed) / (numOfAnimals + 1)
	#averageSense = (averageSense * numOfAnimals + animal.senseRad) / (numOfAnimals + 1)
	#numOfAnimals += 1
	#averageSpeedLabel.text = "Average Speed: " + str(int(averageSpeed))
	#averageSenseLabel.text = "Average Sense: " + str(int(averageSense))

func whenAnimalDied(animal):
	pass
	#averageSpeed = (averageSpeed * numOfAnimals - animal.speed) / (numOfAnimals - 1)
	#averageSense = (averageSense * numOfAnimals - animal.senseRad) / (numOfAnimals - 1)
	#numOfAnimals -= 1
	#averageSpeedLabel.text = "Average Speed: " + str(int(averageSpeed))
	#averageSenseLabel.text = "Average Sense: " + str(int(averageSense))
	#totalAnimal.text = "# of Animals: " + str(numOfAnimals)

func _on_LineEdit_text_entered(new_text):
	if int(new_text) >= 1:
		animalSpeed = int(new_text)
	else:
		animalSpeed = 500

func _on_OptionButton_item_selected(index):
	get_tree().call_group("animals", "update_modulate", index)
