extends Area2D

var leftWall
var upWall
var rightWall
var downWall

var rng = RandomNumberGenerator.new()

var numOfSeedsNearBy = 0
var offset = 75

var nutritionalValue = 10000
var appetizingValue = 1
var seedDelay = 10

func _ready():
	rng.randomize()
	seedDelay = rng.randf_range(8, 12)
	$Timer.wait_time = seedDelay

	leftWall = get_tree().get_root().get_node("World").get_node("left").position.x
	upWall = get_tree().get_root().get_node("World").get_node("up").position.y
	rightWall = get_tree().get_root().get_node("World").get_node("right").position.x
	downWall = get_tree().get_root().get_node("World").get_node("down").position.y
	
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
	child.nutritionalValue = nutritionalValue + rng.randf_range(-100, 100)
	
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

#func _on_Area2D_area_exited(area):
#	if area.name != self.name && "food" in area.name:
#		numOfSeedsNearBy-=1
