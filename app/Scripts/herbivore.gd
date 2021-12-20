extends "res://Scripts/animal.gd"

onready var herbName = $NameLabel

var moveAwayTarget = false
var preyName = ""
var radDirection = 0

func _ready():
	on_change_trait(visible_trait)
	traitLabel = $TraitValueLabel
	rng.randomize()
	waittime = timer.wait_time
	set_sense_rad(senseRad)
	maxX = get_tree().get_root().get_node("World").get_node("right").position.x
	maxY = get_tree().get_root().get_node("World").get_node("down").position.y
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
			calculateDirection(get_tree().get_root().get_node("World").get_node("foodGroup").get_node(targetName))
		timedout = false
		
		
	vector = Vector2(delta * xDir * (speed * currentRunCoeff) * waittime, delta * yDir * (speed * currentRunCoeff) * waittime)
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
		currentRunCoeff = 1

func create_child():
	var animal = load("res://Scenes/herbivore.tscn").instance()
	
	set_next_gen_traits(animal)
	
	get_tree().get_root().get_node("World").get_node("animalGroup").call_deferred("add_child", animal)
	get_tree().get_root().get_node("World").whenAnimalCreated(animal)
		
func _on_SenseDetection_area_entered(area):
	if moveToTarget or moveAwayTarget or !"food" in area.name:
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
	yDir = -yDir
	xDir = -xDir

func _on_SenseDetection_body_exited(body):
	if(moveAwayTarget && body.name == preyName):
		preyName = ""
		moveAwayTarget = false
		currentRunCoeff = 1

