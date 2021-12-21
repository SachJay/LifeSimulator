extends KinematicBody2D

var maxX = 100
var maxY = 100

#setup variables
onready var timer = $Timer
onready var traitLabel = $TraitValueLabel

var waittime
var rng = RandomNumberGenerator.new()
var timedout = false
var foodConsumed = 0
var numOfTraits = 3

## VARIABLES ##
var startingEnergy = pow(450, numOfTraits)
var energy = startingEnergy

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
var xDir = 0.0
var yDir = 0.0
var vector

var moveToTarget = false
var targetName = ""
var offset = 25
var reproduceAmount = 1
var postreproduceAmount = 0

var age = 0
var maxAge = 500

enum {SPEED, SENSE, RUN, CARN, ALL}
var visible_trait = SPEED

func _on_Timer_timeout(): 
	timedout = true
	age += 1
	energy -= get_energy_cost()
	
	if age > maxAge:
		get_tree().get_root().get_node("World").whenAnimalDied(self)
		self.queue_free()
	
	if energy < 0: 
		consume_food()
		energy = startingEnergy

func get_energy_cost():
	return pow(speed/speedConstant, speedCoefficient) * pow(senseRad/senseConstant, senseCoefficient) * pow(runCoeff/runConstant, runEnergyCoeff)

func consume_food():
	if foodConsumed == 0:
		get_tree().get_root().get_node("World").whenAnimalDied(self)
		self.queue_free()
	else:
		foodConsumed -= 1

func eat_food():
	if foodConsumed > reproduceAmount:
		foodConsumed = postreproduceAmount
		create_child()
	else:
		foodConsumed += 1
	moveToTarget = false
	currentRunCoeff = 1

func create_child():
	pass #abstract this shit

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

	if abs(xDist) < 1:
		xDir = 0.0
		yDir = 1.0 / 2.0
		return

	if abs(yDist) < 1:
		xDir = 1.0 / 2.0
		yDir = 0
		return

	if abs(xDist) > abs(yDist):
		xDir = xDist / abs(xDist) / 2.0
		yDir = yDist / abs(xDist) / 2.0
	else:
		yDir = yDist / abs(yDist) / 2.0
		xDir = xDist / abs(yDist) / 2.0
		
func trait_formatter(input, minInput, maxInput):
	if input < minInput:
		return minInput
	
	if input > maxInput:
		return maxInput
	
	return input
	
func handle_wall_collision(body):
	pass

func wall_tp(body):
	if "up" in body.name:
		self.position.y = maxY-offset

	elif "down" in body.name:
		self.position.y = offset

	elif "left" in body.name:
		self.position.x = maxX-offset

	elif "right" in body.name:
		self.position.x = offset

func set_next_gen_traits(animal):
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
