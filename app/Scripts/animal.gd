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
var speed = 1000
var speedConstant = 10000

#movement variables
var xDir = 0
var yDir = 0
var vector

func _ready():
	rng.randomize()
	waittime = timer.wait_time
	self.modulate = Color(map_speed(speed), 0, 0)
	
func _physics_process(delta):
	vector = Vector2(delta * xDir * speed * waittime, delta * yDir * speed * waittime)
	move_and_collide(vector)
	
	if timedout:
		xDir = rng.randf_range(-10.0, 10.0)
		yDir = rng.randf_range(-10.0, 10.0)
		timedout = false

func _on_Timer_timeout(): 
	timedout = true
	energy -= pow(speed, 1.25)/speedConstant 
	
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

func create_child():
	var animal = load("res://Scenes/animal.tscn").instance()
	speed = get_tree().get_root().get_node("World").animalSpeed
	
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
	return map(100, 1500, 0, 1, speedValue) 
