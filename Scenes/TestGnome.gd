extends CharacterBody2D

@export var max_speed := 300
@export var acceleration := 50
@export var friction := 40

var lookLeft := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Input direction to movement
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	if direction.x:
		#Avoid 1frame-turn-arround bug
		if direction.x * velocity.x >= 0:
			#Accelerate
			velocity.x = move_toward(velocity.x, direction.x * max_speed, acceleration)
		else:
			#On turn around: Decelaretion based on friction, not acceleration
			velocity.x = move_toward(velocity.x, direction.x * max_speed, friction)
	else:
		velocity.x = move_toward(velocity.x, direction.x * max_speed, friction)
	
	if direction.y:
		#Avoid 1frame-turn-arround bug
		if direction.y * velocity.y >= 0:
			#Accelerate
			velocity.y = move_toward(velocity.y, direction.y * max_speed, acceleration)
		else:
			#On turn around: Decelaretion based on friction, not acceleration
			velocity.y = move_toward(velocity.y, direction.y * max_speed, friction)
	else:
		velocity.y = move_toward(velocity.y, direction.y * max_speed, friction)
	
	move_and_slide()
	
	# Sprite Flip
	if direction.x <= -0.15:
		$TestGnomeImage.flip_h = true
		lookLeft = true
	if direction.x >= 0.15:
		$TestGnomeImage.flip_h = false
		lookLeft = false
		
