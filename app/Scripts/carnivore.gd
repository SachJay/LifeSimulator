extends "res://Scripts/animal.gd"

func _init():
	speed = 1200.0
	senseRad = 75
	startingEnergy = 3500000
	speedVariance = 300
	senseVariance = 30
	postreproduceAmount = 1
	reproduceAmount = 1
	maxAge = 10000
	
func _ready():
	set_sense_rad(senseRad)
	rng.randomize()
	waittime = timer.wait_time
	maxX = get_tree().get_root().get_node("World").get_node("right").position.x
	maxY = get_tree().get_root().get_node("World").get_node("down").position.y
	
func _physics_process(delta):
	
	if moveToTarget and !get_tree().get_root().get_node("World").get_node("animalGroup").has_node(targetName):
		moveToTarget = false
	
	if timedout:
		if !moveToTarget:
			xDir = rng.randf_range(-1.0, 1.0)
			yDir = rng.randf_range(-1.0, 1.0)
		else:
			calculateDirection(get_tree().get_root().get_node("World").get_node("animalGroup").get_node(targetName))
		timedout = false
		
	vector = Vector2(delta * xDir * speed * waittime, delta * yDir * speed * waittime)
	return move_and_collide(vector)

func _on_Area2D_body_entered(body):
	if "herb" in body.name:
		eat_food()
		body.queue_free()
		
	handle_wall_collision(body)

func create_child():
	var animal = load("res://Scenes/carnivore.tscn").instance()
	
	set_next_gen_traits(animal)
	
	get_tree().get_root().get_node("World").get_node("animalGroup").call_deferred("add_child", animal)
	get_tree().get_root().get_node("World").whenAnimalCreated(animal)

func _on_SenseDetection_body_entered(body):
	if moveToTarget or !"herb" in body.name:
		return
		
	calculateDirection(body)

func _on_SenseDetection_body_exited(body):
	if(moveToTarget && body.name == targetName):
		targetName = ""
		moveToTarget = false
