extends Area2D

var leftWall
var upWall
var rightWall
var downWall

var rng = RandomNumberGenerator.new()

var timedout = false
var age = 0;
var numOfSeedsNearBy = 0
var offset = 75

var nutritionalValue = pow(450, 3)

func _ready():
	rng.randomize()
	leftWall = get_tree().get_root().get_node("World").get_node("left").position.x
	upWall = get_tree().get_root().get_node("World").get_node("up").position.y
	rightWall = get_tree().get_root().get_node("World").get_node("right").position.x
	downWall = get_tree().get_root().get_node("World").get_node("down").position.y

func _process(delta):
	if timedout:			
		timedout = false
	
func _on_Timer_timeout(): 
	timedout = true
	age += 1
	
	if numOfSeedsNearBy < 2 and age % 7 == 0 and get_tree().get_root().get_node("World").numOfFood < 500:
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
	child.nutritionalValue = pow(450 + rng.randf_range(-10, 10), 3)

func die():
	self.queue_free()
	
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
	if area.name != self.name && "food" in area.name:
		numOfSeedsNearBy+=1
		if age < 5 and numOfSeedsNearBy > 1:
			self.queue_free()


func _on_Area2D_area_exited(area):
	if area.name != self.name && "food" in area.name:
		numOfSeedsNearBy-=1
