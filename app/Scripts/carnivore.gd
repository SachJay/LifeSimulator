extends "res://Scripts/animal.gd"

onready var herbName = $NameLabel

func _init():
	speed = 1100.0
	senseRad = 70
	startingEnergy = pow(meatEnergy, numOfTraits)
	energy = startingEnergy
	speedVariance = 300
	senseVariance = 30
	runVariance = 0.6
	reproduceAmount = 2
	hungryEnergyLevel = 1
	
	maxAge = 10000
	
func _ready():
	common_ready()
	herbName.text = self.name
	
func _physics_process(delta):
	
	if moveToTarget and !get_tree().get_root().get_node("World").get_node("animalGroup").has_node(targetName):
		moveToTarget = false
		currentRunCoeff = 1
	
	if timedout:
		if !moveToTarget:
			radianDirection = radianDirection + rng.randf_range(-PI*1/3, PI*1/3)
		else:
			calculateDirection(get_tree().get_root().get_node("World").get_node("animalGroup").get_node(targetName))
		timedout = false
	
	vector = Vector2(delta * cos(radianDirection) * (speed * currentRunCoeff) * waittime, delta * sin(radianDirection) * (speed * currentRunCoeff) * waittime)
	return move_and_collide(vector)

func _on_Area2D_body_entered(body):
	if "herb" in body.name and !isFull:
		eat_food(body)
		body.queue_free()
		
	handle_wall_collision(body)

func _on_SenseDetection_body_entered(body):
	if !"herb" in body.name or isFull:
		return
	
	if moveToTarget:
		var prey = get_tree().get_root().get_node("World").get_node("animalGroup").get_node(targetName)
		if prey.speed * prey.runCoeff < body.speed * body.runCoeff:
			return
		
	targetName = body.name
	moveToTarget = true
	currentRunCoeff = runCoeff
	calculateDirection(body)

func _on_SenseDetection_body_exited(body):
	if(moveToTarget && body.name == targetName):
		targetName = ""
		moveToTarget = false
		currentRunCoeff = 1
