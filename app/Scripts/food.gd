extends Area2D

onready var traitLabel = $TraitValueLabel

var leftWall
var upWall
var rightWall
var downWall

var rng = RandomNumberGenerator.new()

var numOfSeedsNearBy = 0
var offset = 75

var nutritionalValue = 10000.0
var appetizingValue = 75.0
var chanceOfGettingEaten = 75
var seedDelay = 10

enum {NUTRITENT, ATTRACTIVENESS, EATEN}
var visible_trait = NUTRITENT

func _ready():
	on_change_trait(visible_trait)
	rng.randomize()
	seedDelay = rng.randf_range(8, 12)
	$Timer.wait_time = seedDelay

	leftWall = get_tree().get_root().get_node("World").get_node("left").position.x
	upWall = get_tree().get_root().get_node("World").get_node("up").position.y
	rightWall = get_tree().get_root().get_node("World").get_node("right").position.x
	downWall = get_tree().get_root().get_node("World").get_node("down").position.y
	calculate_chance()
	
func calculate_chance():
	chanceOfGettingEaten = (nutritionalValue - 10000.0) / 100.0 + appetizingValue - 30.0
	
func _on_Timer_timeout(): 
	if numOfSeedsNearBy < 2 and get_tree().get_root().get_node("World").numOfFood < 500:
		create_child_food()

func create_child_food():
		var food = load("res://Scenes/food.tscn").instance()
		set_next_gen_traits(food)
		
		get_tree().get_root().get_node("World").get_node("foodGroup").call_deferred("add_child", food)
	#get_tree().get_root().get_node("World").(animal)

func set_next_gen_traits(child):
	rng.randomize()
	var rad = rng.randf_range(-PI * 2, PI * 2)
	child.position.x = check_boundaries_x(self.position.x + cos(rad) * rng.randf_range(125, 600))
	child.position.y = check_boundaries_y(self.position.y + sin(rad) * rng.randf_range(125, 600))
	child.nutritionalValue = trait_formatter(nutritionalValue + rng.randf_range(-500, 500), 5000, 20000)
	child.appetizingValue = trait_formatter(appetizingValue + rng.randf_range(-5, 5), 0, 100)
	child.calculate_chance()
	child.visible_trait = visible_trait
	child.modulate = visualise_trait(visible_trait)
	
func check_boundaries_x(posi):
	if posi < leftWall+offset:
		posi = leftWall+offset
	
	if posi > rightWall-offset:
		posi = rightWall-offset
		
	return posi
	
func check_boundaries_y(posi):
	if posi < upWall+offset:
		posi = upWall+offset
	
	if posi > downWall-offset:
		posi = downWall-offset
		
	return posi

func _on_Area2D_area_entered(area):
	#print(area.name)
	if area.name != self.name && "food" in area.name:
		numOfSeedsNearBy += 1

func trait_formatter(input, minInput, maxInput):
	if input < minInput:
		return minInput
	
	if input > maxInput:
		return maxInput
	
	return input
#func _on_Area2D_area_exited(area):
#	if area.name != self.name && "food" in area.name:
#		numOfSeedsNearBy-=1

func on_change_trait(trait):
	visible_trait = trait
	self.modulate = visualise_trait(trait)
	traitLabel.text = set_trait_value_label(trait)
	
func visualise_trait(trait):
	if trait == NUTRITENT:
		return Color(map(7000, 13000, 0, 1, nutritionalValue), 0, 0)
	elif trait == ATTRACTIVENESS:
		return Color(0, map(25, 75, 0, 1, appetizingValue), 0)
	elif trait == EATEN:
		return Color(0, 0, map(25, 75, 0, 1, chanceOfGettingEaten))
	
func set_trait_value_label(trait):
	if trait == NUTRITENT:
		return str("%.2f" % nutritionalValue)
	elif trait == ATTRACTIVENESS:
		return str("%.2f" % appetizingValue)
	elif trait == EATEN:
		return str("%.2f" % chanceOfGettingEaten)

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
