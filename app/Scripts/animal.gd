extends KinematicBody2D

var leftWall
var upWall
var rightWall
var downWall

#setup variables
onready var timer = $Timer
onready var traitLabel = $TraitValueLabel

var waittime
var rng = RandomNumberGenerator.new()
var timedout = false
var numOfTraits = 3

## VARIABLES ##
var startingEnergy = pow(450, numOfTraits)
var energy = startingEnergy
var meatEnergy = 500

#Speed
var startingSpeed = 1000.0
var speed = startingSpeed
var speedConstant = 20
var speedCoefficient = 1.35
var speedVariance = 100.0

#Run 
var startingRunCoeff = 2.0
var runCoeff = startingRunCoeff
var runConstant = 0.04
var runEnergyCoeff = 1.1
var runVariance = 0.3

var currentRunCoeff = 1.0

#Sense
var startingSenseRad = 50
var senseRad = startingSenseRad
var senseConstant = 1
var senseCoefficient = 1
var senseVariance = 10

#movement variables
var vector
var radianDirection = 0

var moveToTarget = false
var targetName = ""
var offset = 25

#reproduction variables
var reproduceAmount = 2
var hungryEnergyLevel = 1
var isFull = false

var age = 0
var maxAge = 500

enum {SPEED, SENSE, RUN, CARN, ALL}
var visible_trait = SPEED

var nutritionalValue = pow(meatEnergy, numOfTraits)

func common_ready():
	on_change_trait(visible_trait)
	rng.randomize()
	waittime = timer.wait_time
	set_sense_rad(senseRad)
	
	leftWall = get_tree().get_root().get_node("World").get_node("left").position.x
	upWall = get_tree().get_root().get_node("World").get_node("up").position.y
	rightWall = get_tree().get_root().get_node("World").get_node("right").position.x
	downWall = get_tree().get_root().get_node("World").get_node("down").position.y
	
func _on_Timer_timeout(): 
	timedout = true
	age += 1
	energy -= get_energy_cost()
	
	if age > maxAge:
		get_tree().get_root().get_node("World").whenAnimalDied(self)
		self.queue_free()
	
	if energy < startingEnergy * hungryEnergyLevel: 
		isFull = false
		
	if energy < 0: 
		get_tree().get_root().get_node("World").whenAnimalDied(self)
		self.queue_free()

func get_energy_cost():
	return pow(speed/speedConstant, speedCoefficient) * pow(senseRad/senseConstant, senseCoefficient) * pow(runCoeff/runConstant, runEnergyCoeff)

func eat_food(food):
	if energy > startingEnergy*reproduceAmount and isFull == false:
		isFull = true
		create_child()
	else:
		energy += food.nutritionalValue
	moveToTarget = false
	currentRunCoeff = 1

func create_child():
	pass
	
func create_animal(animal):
	set_next_gen_traits(animal)
	
	get_tree().get_root().get_node("World").get_node("animalGroup").call_deferred("add_child", animal)
	get_tree().get_root().get_node("World").whenAnimalCreated(animal)

func map(inputLow, inputHigh, outputLow, outputHigh, value):
	#print(str(inputLow)+" "+str(inputHigh)+" "+str(value))
	if value < inputLow:
		return outputLow
	
	if value > inputHigh:
		return outputHigh
		
	var inputRange:float = inputHigh - inputLow
	var outputRange:float = outputHigh - outputLow
	var percent:float = (value - inputLow) / inputRange
	
	return outputLow + outputRange * percent

func map_trait(coefficient, constant, starting, value):
	#print(str(calculate_map_range_low(coefficient, constant, starting)) +"  "+str(calculate_map_range_high(coefficient, constant, starting)))
	var color = map(calculate_map_range_low(coefficient, constant, starting), calculate_map_range_high(coefficient, constant, starting), 0, 1, value)
	return color

func calculate_map_range_low(coeff, constVar, starting):
	var variance =  startingEnergy / (3000000.0 * pow(coeff, 3))
	return starting - variance * constVar * 2 / 5

func calculate_map_range_high(coeff, constVar, starting):
	var variance =  startingEnergy / (3000000.0 * pow(coeff, 3))
	return starting + variance * constVar * 11 / 5

func distance(x1, y1, x2, y2):
	return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2))

func set_sense_rad(senseRadInput):
	var shape = CircleShape2D.new()
	shape.set_radius(senseRadInput)
	$SenseDetection/CollisionShape2D.shape = shape
	
	senseRad = senseRadInput

func calculateDirection(body):
	var xDist:float = body.position.x - self.position.x
	var yDist:float = body.position.y - self.position.y

	radianDirection = atan2(yDist, xDist)
		
func trait_formatter(input, minInput, maxInput):
	if input < minInput:
		return minInput
	
	if input > maxInput:
		return maxInput
	
	return input
	
func handle_wall_collision(body):
	wall_tp(body)

func wall_tp(body):
	if "up" in body.name:
		self.position.y = downWall-offset

	elif "down" in body.name:
		self.position.y = upWall+offset

	elif "left" in body.name:
		self.position.x = rightWall-offset

	elif "right" in body.name:
		self.position.x = leftWall+offset

func set_next_gen_traits(animal):
	rng.randomize()
	animal.position = self.position
	animal.speed = trait_formatter(speed + rng.randf_range(-speedVariance, speedVariance), 250, 4000)
	animal.runCoeff = trait_formatter(runCoeff + rng.randf_range(-runVariance, runVariance), 1, 5)
	animal.set_sense_rad(trait_formatter(senseRad + rng.randf_range(-senseVariance, senseVariance), 20, 400))
	animal.modulate = visualise_trait(visible_trait)
	animal.visible_trait = visible_trait

func visualise_trait(trait):
	if trait == SPEED:
		return Color(map_trait(speedCoefficient, speedConstant, startingSpeed, speed), 0, 0)
	elif trait == SENSE:
		return Color(0, map_trait(senseCoefficient, senseConstant, startingSenseRad, senseRad), 0)
	elif trait == RUN:
		return Color(0, 0, map_trait(runEnergyCoeff, runConstant, startingRunCoeff, runCoeff))
	elif trait == CARN:
		if "carn" in self.name:
			return Color(0, 0, 0)
		else:
			return Color(1, 1, 1)
	elif trait == ALL:
		return Color(map_trait(speedCoefficient, speedConstant, startingSpeed, speed), map_trait(senseCoefficient, senseConstant, startingSenseRad, senseRad), map_trait(runEnergyCoeff, runConstant, startingRunCoeff, runCoeff))

func set_trait_value_label(trait):
	if trait == SPEED:
		return str("%.2f" % speed)
	elif trait == SENSE:
		return str("%.2f" % senseRad)
	elif trait == RUN:
		return str("%.2f" % runCoeff)
	elif trait == CARN:
		if "carn" in self.name:
			return "CARN"
		else:
			return "HERB"
	elif trait == ALL:
		return ""
	else:
		return "ERROR"

func on_change_trait(trait):
	visible_trait = trait
	self.modulate = visualise_trait(trait)
	traitLabel.text = set_trait_value_label(trait)
