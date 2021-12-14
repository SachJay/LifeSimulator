extends KinematicBody2D

onready var timer = $Timer
var waittime

var rng = RandomNumberGenerator.new()
var timedout = false

var xVelo = 500
var yVelo = 500
var xDir = 500
var yDir = 500
var foodConsumed = 0
var vector

func _ready():
	rng.randomize()
	waittime = timer.wait_time
	
func _physics_process(delta):
	
	#rng.randf_range(-10.0, 10.0)
	vector = Vector2(delta * xDir * xVelo * waittime, delta * yDir * yVelo * waittime)
	move_and_collide(vector)
	
	if timedout:
		xDir = rng.randf_range(-10.0, 10.0)
		yDir = rng.randf_range(-10.0, 10.0)
		
		timedout = false

func _on_Timer_timeout():
	timedout = true

func _on_Area2D_body_entered(body):
	if "food" in body.name:
		foodConsumed += 1
		body.queue_free()
		
func consume_food():
	if foodConsumed == 0:
		self.queue_free()
	else:
		foodConsumed -= 1
		
func _on_Area2D_area_entered(area):
	if "food" in area.name:
		if foodConsumed == 2:
			var animal = load("res://Scenes/animal.tscn").instance()
			self.add_child(animal)
		else:
			foodConsumed += 1
		area.queue_free()
