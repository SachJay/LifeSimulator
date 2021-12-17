extends "res://Scripts/animal.gd"

var moveAwayTarget = false
var preyName = ""
var radDirection = 0

func _ready():
	rng.randomize()
	waittime = timer.wait_time
	set_sense_rad(senseRad)
	maxX = get_tree().get_root().get_node("World").get_node("right").position.x
	maxY = get_tree().get_root().get_node("World").get_node("down").position.y
	
func _physics_process(delta):
	if moveToTarget and !get_tree().get_root().get_node("World").get_node("foodGroup").has_node(targetName):
		moveToTarget = false
	
	if moveAwayTarget and !get_tree().get_root().get_node("World").get_node("animalGroup").has_node(preyName):
		moveAwayTarget = false
		
	if timedout:
		if moveAwayTarget:
			moveAwayTarget = true
			calculateDirection(get_tree().get_root().get_node("World").get_node("animalGroup").get_node(preyName))
			yDir = -yDir
			xDir = -xDir
		elif !moveToTarget:
		
			if xDir != 0:
				radDirection = tan(yDir/xDir)
			else:
				radDirection = 1
			
			#radDirection = radDirection + rng.randf_range(-PI / 2, PI / 2)

			radDirection = rng.randf_range(-PI * 2, PI * 2)
			xDir = sin(radDirection)
			yDir = cos(radDirection)

		elif moveToTarget:
			moveToTarget = true
			calculateDirection(get_tree().get_root().get_node("World").get_node("foodGroup").get_node(targetName))
		timedout = false
		
		
	vector = Vector2(delta * xDir * speed * waittime, delta * yDir * speed * waittime)
	return move_and_collide(vector)

func _on_Area2D_body_entered(body):
	handle_wall_collision(body)
		
func _on_Area2D_area_entered(area):
	if "food" in area.name:
		if foodConsumed > 2:
			foodConsumed = 1
			create_child()
		else:
			foodConsumed += 1
		area.queue_free()
		moveToTarget = false

func create_child():
	var animal = load("res://Scenes/herbivore.tscn").instance()
	
	set_next_gen_traits(animal)
	
	get_tree().get_root().get_node("World").get_node("animalGroup").call_deferred("add_child", animal)
	get_tree().get_root().get_node("World").whenAnimalCreated(animal)
		
func _on_SenseDetection_area_entered(area):
	if moveToTarget or moveAwayTarget or !"food" in area.name:
		return
		
	moveToTarget = true
	targetName = area.name
	calculateDirection(area)

func _on_SenseDetection_body_entered(body):
	if !"carn" in body.name:
		return
	
	moveAwayTarget = true
	preyName = body.name
	calculateDirection(body)
	yDir = -yDir
	xDir = -xDir

func _on_SenseDetection_body_exited(body):
	if(moveAwayTarget && body.name == preyName):
		preyName = ""
		moveAwayTarget = false

