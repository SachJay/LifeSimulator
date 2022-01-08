extends Node

onready var totalHerb = $CanvasLayer2/TotalHerb
onready var totalCarn = $CanvasLayer2/TotalCarn
onready var totalFood = $CanvasLayer2/TotalFood
onready var timeElapsedLabel = $CanvasLayer2/TimeElapsedLabel
onready var camera = $MainCamera

onready var animalTraitDropdown = $CanvasLayer2/OptionButton
onready var foodTraitDropdown = $CanvasLayer2/OptionButton2

onready var leftWall = $left
onready var upWall = $up
onready var rightWall = $right
onready var downWall = $down

var food_trait_value = 0

var rng = RandomNumberGenerator.new()

var counter = 0
var minX
var minY
var maxX
var maxY
var offset = 100

#Animal Variables
var animalSpeed = 500

var averageSpeed = 2000
var averageSense = 50

var cameraX = ProjectSettings.get_setting("display/window/size/width")
var cameraY = ProjectSettings.get_setting("display/window/size/height")

var numOfFood = 0
var numOfHerb = 0

func _ready():
	minX = leftWall.position.x
	minY = upWall.position.y
	maxX = rightWall.position.x
	maxY = downWall.position.y
	
	for _n in range(0,40):
		var animal = load("res://Scenes/carnivore.tscn").instance()
		animal.position.x = rng.randf_range(minX+offset, maxX-offset) 
		animal.position.y = rng.randf_range(minY+offset, maxY-offset)
		self.get_node("animalGroup").call_deferred("add_child", animal)
	
	for _n in range(0,300):
		var animal = load("res://Scenes/herbivore.tscn").instance()
		animal.position.x = rng.randf_range(minX+offset, maxX-offset) 
		animal.position.y = rng.randf_range(minY+offset, maxY-offset)
		self.get_node("animalGroup").call_deferred("add_child", animal)
		
	for _n in range(1,500):
		create_food()
		
	numOfHerb = get_tree().get_nodes_in_group("herb").size()
	totalHerb.text = "# of Herbs: " + str(numOfHerb)
	numOfFood = get_tree().get_nodes_in_group("food").size()
	totalFood.text = "# of Food: " + str(numOfFood)
	totalCarn.text = "# of Carns: " + str(get_tree().get_nodes_in_group("carn").size())
	
	animalTraitDropdown.add_item("Speed")
	animalTraitDropdown.add_item("Sense")
	animalTraitDropdown.add_item("Run")
	animalTraitDropdown.add_item("Carn")
	animalTraitDropdown.add_item("All")
	
	foodTraitDropdown.add_item("Nutrient")
	foodTraitDropdown.add_item("Attractiveness")
	foodTraitDropdown.add_item("Eaten Chance")
	
	get_tree().call_group("animals", "on_change_trait", 0)

func _process(delta):

	camera.zoom.x += delta * (Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out")) * 5
	camera.zoom.y += delta * (Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out")) * 5
	if(camera.zoom.x < 0.1):
		camera.zoom.x = 0.1
	
	if(camera.zoom.y < 0.1):
		camera.zoom.y = 0.1

	if(camera.zoom.x*cameraX > maxX - minX):
		camera.zoom.x = (maxX - minX) / cameraX

	if(camera.zoom.y*cameraY > maxY - minY):
		camera.zoom.y = (maxY - minY) / cameraY

	camera.position.x += delta * (Input.get_action_strength("run_right") - Input.get_action_strength("run_left")) * 2000
	camera.position.y -= delta * (Input.get_action_strength("run_up") - Input.get_action_strength("run_down")) * 2000
	
	if camera.position.y < minY+(cameraY*camera.zoom.y)/2:
		camera.position.y = minY+(cameraY*camera.zoom.y)/2

	if camera.position.y > maxY-(cameraY*camera.zoom.y)/2:
		camera.position.y = maxY-(cameraY*camera.zoom.y)/2
	
	if camera.position.x < minX+(cameraX*camera.zoom.x)/2:
		camera.position.x = minX+(cameraX*camera.zoom.x)/2

	if camera.position.x > maxX-(cameraX*camera.zoom.x)/2:
		camera.position.x = maxX-(cameraX*camera.zoom.x)/2

func _on_Timer_timeout():
	counter+=1

	if counter % 1 == 0:  
		timeElapsedLabel.text = "Time Elapsed: " + str(counter)

	if counter % 5 == 0:
		if numOfFood < 100:
			for _n in range(1,10):
				create_food()
			
		numOfHerb = get_tree().get_nodes_in_group("herb").size()
		totalHerb.text = "# of Herbs: " + str(numOfHerb)
		totalCarn.text = "# of Carns: " + str(get_tree().get_nodes_in_group("carn").size())
		numOfFood = get_tree().get_nodes_in_group("food").size()
		totalFood.text = "# of Food: " + str(numOfFood)

func create_food():
	var food = load("res://Scenes/food.tscn").instance()
	food.nutritionalValue = rng.randf_range(9000, 11000)
	food.appetizingValue = rng.randf_range(60, 90)
	food.calculate_chance()
	food.visible_trait = food_trait_value
	food.position.x = rng.randf_range(minX+offset, maxX-offset) 
	food.position.y = rng.randf_range(minY+offset, maxY-offset)
	self.get_node("foodGroup").add_child(food)
			
#func whenAnimalCreated(animal):
#	pass
	#averageSpeed = (averageSpeed * numOfAnimals + animal.speed) / (numOfAnimals + 1)
	#averageSense = (averageSense * numOfAnimals + animal.senseRad) / (numOfAnimals + 1)
	#numOfAnimals += 1
	#averageSpeedLabel.text = "Average Speed: " + str(int(averageSpeed))
	#averageSenseLabel.text = "Average Sense: " + str(int(averageSense))

#func whenAnimalDied(animal):
#	pass
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
	get_tree().call_group("animals", "on_change_trait", index)

func _on_OptionButton2_item_selected(index):
	food_trait_value = index
	get_tree().call_group("food", "on_change_trait", index)
