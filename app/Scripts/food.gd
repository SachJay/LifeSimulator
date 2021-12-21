extends KinematicBody2D

var rng = RandomNumberGenerator.new()

var timedout = false
var age = 0;
var numOfSeedsNearBy = 0

func _ready():
	rng.randomize()

func _process(delta):
	if timedout:			
		timedout = false
	
func _on_Timer_timeout(): 
	timedout = true
	age += 1
	
	if numOfSeedsNearBy < 4 and age % 5 == 0:
		create_child_food()

func create_child_food():
	var food = load("res://Scenes/food.tscn").instance()
	set_next_gen_traits(food)
	
	get_tree().get_root().get_node("World").get_node("foodGroup").call_deferred("add_child", food)
	#get_tree().get_root().get_node("World").(animal)

func set_next_gen_traits(animal):
	animal.position.x = self.position.x + rng.randf_range(-100.0, 100.0)
	animal.position.y = self.position.y + rng.randf_range(-100.0, 100.0)
	
func die():
	self.queue_free()

func _on_Area2D_body_entered(body):
	if body.name != self.name && "food" in body.name:
		numOfSeedsNearBy+=1
