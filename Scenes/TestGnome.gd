extends CharacterBody2D

@export var speed := 500

var lookLeft := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Input direction to movement
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * speed
	move_and_slide()
	
	# Sprite Flip
	if direction.x <= -0.15:
		$TestGnomeImage.flip_h = true
		lookLeft = true
	if direction.x >= 0.15:
		$TestGnomeImage.flip_h = false
		lookLeft = false
		
		
