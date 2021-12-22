extends "res://Scripts/animal.gd"

onready var herbName = $NameLabel

var moveAwayTarget = false
var preyName = ""

func _ready():
	common_ready()
	traitLabel = $TraitValueLabel
	herbName.text = self.name
	
func _physics_process(delta):
	if moveToTarget and !get_tree().get_root().get_node("World").get_node("foodGroup").has_node(targetName):
		moveToTarget = false
		currentRunCoeff = 1
	
	if moveAwayTarget and !get_tree().get_root().get_node("World").get_node("animalGroup").has_node(preyName):
		moveAwayTarget = false
		currentRunCoeff = 1
		
	if timedout:
		if moveAwayTarget:
			calculateDirection(get_tree().get_root().get_node("World").get_node("animalGroup").get_node(preyName))
			radianDirection += PI
		elif !moveToTarget:
			radianDirection = radianDirection + rng.randf_range(-PI*1/3, PI*1/3)
			
		elif moveToTarget:
			calculateDirection(get_tree().get_root().get_node("World").get_node("foodGroup").get_node(targetName))
		timedout = false
		
	vector = Vector2(delta * cos(radianDirection) * (speed * currentRunCoeff) * waittime, delta * sin(radianDirection) * (speed * currentRunCoeff) * waittime)
	return move_and_collide(vector)

func _on_Area2D_body_entered(body):
	handle_wall_collision(body)
		
func _on_Area2D_area_entered(area):
	if "food" in area.name and !isFull:
		eat_food(area)
		area.queue_free()

func create_child():
	var animal = load("res://Scenes/herbivore.tscn").instance()
	create_animal(animal)
	
func _on_SenseDetection_area_entered(area):
	if moveToTarget or moveAwayTarget or !"food" in area.name or isFull:
		return
		
	moveToTarget = true
	currentRunCoeff = runCoeff
	targetName = area.name
	calculateDirection(area)

func _on_SenseDetection_body_entered(body):
	if !"carn" in body.name:
		return
	
	moveAwayTarget = true
	currentRunCoeff = runCoeff
	preyName = body.name
	calculateDirection(body)
	calculateDirection(body)
	radianDirection += PI 

func _on_SenseDetection_body_exited(body):
	if(moveAwayTarget && body.name == preyName):
		preyName = ""
		moveAwayTarget = false
		currentRunCoeff = 1

