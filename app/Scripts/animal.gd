extends KinematicBody2D

#setup variables
onready var timer = $Timer
var waittime
var rng = RandomNumberGenerator.new()
var timedout = false
var foodConsumed = 0

#stat variables
var startingEnergy = 300
var energy = startingEnergy
var speed = 2000
var speedConstant = 10000
var senseRad = 1000

#movement variables
var xDir = 0.0
var yDir = 0.0
var vector

var moveToTarget = false
var targetName = ""

func _ready():
	rng.randomize()
	waittime = timer.wait_time
	self.modulate = Color(map_speed(speed), 0, 0)
	$SenseDetection/CollisionShape2D.shape.radius = senseRad #make this a trait and pass it down
	
func _physics_process(delta):
	if moveToTarget and !get_tree().get_root().get_node("World").get_node("foodGroup").has_node(targetName):
		moveToTarget = false
	
	if timedout:
		if !moveToTarget:
			xDir = rng.randf_range(-1.0, 1.0)
			yDir = rng.randf_range(-1.0, 1.0)
		timedout = false
		
	vector = Vector2(delta * xDir * speed * waittime, delta * yDir * speed * waittime)
	move_and_collide(vector)
	
func _on_Timer_timeout(): 
	timedout = true
	energy -= get_energy_cost()
	
	if energy < 0: 
		consume_food()
		energy = startingEnergy

func _on_Area2D_body_entered(body):
	if "food" in body.name:
		foodConsumed += 1
		body.queue_free()
		
func consume_food():
	if foodConsumed == 0:
		get_tree().get_root().get_node("World").whenAnimalDied()
		self.queue_free()
	else:
		foodConsumed -= 1
		
func _on_Area2D_area_entered(area):
	if "food" in area.name:
		if foodConsumed > 2:
			create_child()
		else:
			foodConsumed += 1
		area.queue_free()
	moveToTarget = false

func create_child():
	var animal = load("res://Scenes/animal.tscn").instance()
	
	animal.position = self.position
	animal.speed = speed + rng.randf_range(-100.0, 100.0)
	animal.modulate = Color(map_speed(animal.speed), 0, 0)
	get_tree().get_root().get_node("World").get_node("animalGroup").call_deferred("add_child", animal)
	get_tree().get_root().get_node("World").whenAnimalCreated()

func map(inputLow, inputHigh, outputLow, outputHigh, value):
	if value < inputLow:
		return outputLow
	
	if value > inputHigh:
		return outputHigh
		
	var inputRange:float = inputHigh - inputLow
	var outputRange:float = outputHigh - outputLow
	var percent:float = (value - inputLow) / inputRange
	
	return outputLow + outputRange * percent
	
func map_speed(speedValue):
	return map(1500, 2500, 0, 1, speedValue) 
	
func get_energy_cost():
	return pow(speed, 1.25)/speedConstant 

func _on_SenseDetection_area_entered(area):
	if moveToTarget:
		return
	
	var distinationX = area.position.x
	var distinationY = area.position.y

	var xDist:float = area.position.x - self.position.x
	var yDist:float = area.position.y - self.position.y
	
	moveToTarget = true
	targetName = area.name
	
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
		
func distance(x1, y1, x2, y2):
	return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2))
