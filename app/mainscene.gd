extends KinematicBody2D

# Called when the node enters the scene tree for the first time.
onready var camera = $Camera2D
onready var collisonShape = $CollisionShape2D

func _ready():

	print(self.name)
#	camera.current = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.position.x -= delta * (Input.get_action_strength("run_right") - Input.get_action_strength("run_left")) * 100

func _on_Area2D_area_entered(area):
	print(area.name)
