extends CharacterBody2D

@export var max_speed := 87
@export var speed_up_speed := 150
var start_speed := 87
@export var acceleration := 50
@export var friction := 40
var can_move := true
var moving := false

var canBeAttacked = true : get = was_attacked

# vida #
@export var hp = 3 : set = set_hp

signal OnHp_changed
signal OnDied
# vida #

var key_items_gained : int = 0

var can_attack := false

var can_hide := false
var in_hide_area := false
var hiding := false

var lookLeft := false
var hat_lost := false

var anim_in_progress := false
@onready var anim_body : AnimatedSprite2D = $"Player Sprites".get_node("player_BodySprite")
@onready var anim_hat : AnimatedSprite2D = $"Player Sprites".get_node("PlayerHatSprite")
@onready var anim_attack : AnimationPlayer = $"Player Sprites".get_node("Attack").get_node("Attack_Anim")

@onready var magic_glow : PointLight2D = $"Player Sprites".get_node("Magic_ON").get_node("PointLight2D")
@onready var sweat_ptcl: CPUParticles2D = $"Player Sprites".get_node("CPUParticles2D")
@onready var my_collision : CollisionShape2D = $CollisionShape2D
@onready var timer_attacked := $Timer_Attacked

@onready var hat_off_ptcl : CPUParticles2D = $"Player Sprites".get_node("hatOFF_particle")
@onready var hit_ptcl : CPUParticles2D = $"Player Sprites".get_node("hit_particle")
@onready var madness : Node2D = $"Player Sprites".get_node("locura")


@onready var sfx_attack : AudioStreamPlayer2D = $SFXs.get_node("sfx_PlayerAttack")
@onready var sfx_death : AudioStreamPlayer2D = $SFXs.get_node("sfx_PlayerDeath")
@onready var sfx_hit : AudioStreamPlayer2D = $SFXs.get_node("sfx_PlayerHit")
@onready var sfx_mad : AudioStreamPlayer2D = $SFXs.get_node("sfx_PlayerMad")


# Called when the node enters the scene tree for the first time.
func _ready():
	start_speed = max_speed
	can_move = true
	
	can_hide = true
	in_hide_area = false
	hiding = false
	
	sweat_ptcl.visible = false
	


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
	
	if can_move == true:
		move_and_slide()
		
	#Anims
	if $Timer_Anim.time_left == 0:
		$Timer_Anim.wait_time = 1
		$Timer_Anim.start()
		$Timer_Anim.paused = true
		anim_in_progress = false
		if direction != Vector2(0,0):
			moving = false
		else:
			moving = true
	if direction != Vector2(0,0) && moving == false && anim_in_progress == false && hiding == false:
		moving = true
		anim_body.play("Player_Walk")
		if hat_lost == false:
			anim_hat.play("Hat_Walk")
		
	if direction == Vector2(0,0) && moving == true && anim_in_progress == false && hiding == false:
		moving = false
		anim_body.play("Player_Idle")
		if hat_lost == false:
			anim_hat.play("Hat_Idle")
		
	
	# Hide Action
	if hiding == false && can_hide == true && in_hide_area == true && Input.is_action_just_pressed("Hide"):
		start_hiding()
		
	elif hiding == true && Input.is_action_just_pressed("Hide"):
		stop_hiding()
		
	
	#Attack Action
	if Input.is_action_just_pressed("Attack") && can_attack == true:
		magic_glow.enabled = false
		$Timer_AttackCD.start()
		stop_hiding()
		can_attack = false
		sfx_attack.play()
		
		# Anims
		anim_attack.play("AttackPlayer")
		anim_body.play("Player_Attack")
		if hat_lost == false:
			anim_hat.play("Hat_Attack")
		start_anim(0.9)
		
	if $Timer_AttackCD.time_left == 0 && can_attack == false:
		print("can attack")
		magic_glow.enabled = true
		can_attack = true
	
	
	# Sprite Flip
	if direction.x <= -0.15:
		if lookLeft == false:
			$"Player Sprites".scale.x *= -1
			lookLeft = true
	if direction.x >= 0.15:
		if lookLeft == true:
			$"Player Sprites".scale.x *= -1
			lookLeft = false
		
func start_anim(timer):
		anim_in_progress = true
		$Timer_Anim.paused = false
		$Timer_Anim.wait_time = timer
		$Timer_Anim.start()


func start_hiding():
	my_collision.disabled = true
	can_attack = false
	can_move = false
	hiding = true
	anim_in_progress = true
	anim_body.play("Player_Hidden")
	anim_hat.play("Hat_Hidden")
	print("g'bye")
		
func stop_hiding():
	my_collision.disabled = false
	can_attack = true
	anim_in_progress = false
	can_move = true
	hiding = false
	
	anim_body.play("Player_Idle")
	if hat_lost == false:
		anim_hat.play("Hat_Idle")
	print("yo")
		
	
func cannot_hide():
	can_hide = false
	print("cant h")

func Can_Hide():
	can_hide = true
	print("can h")
		
func speed_up():
	max_speed = speed_up_speed
	sweat_ptcl.visible = true
	
func slow_down():
	max_speed = start_speed
	sweat_ptcl.visible = false


func _on_area_2d_body_entered(body):
	in_hide_area = true
	print("h area")

func _on_area_2d_body_exited(body):
	in_hide_area = false
	print("no h area")

func gain_key_item():
	key_items_gained += 1
	print(key_items_gained)

func heal_dmg( heal ):
	sfx_mad.stop()
	
	if hp <= 2:
		madness.visible = false
		print("se curo")
		set_hp(hp + heal)
		
	if hp == 3:
		anim_hat.play("Hat_Idle")
		hat_lost = false
	
func take_dmg( dmg ):
	print("le pegaron")
	timer_attacked.start()
	canBeAttacked = false
	modulate.a = 0.5
	set_hp(hp - dmg)
	
	if hp >= 1:
		sfx_hit.play()
	
	hit_ptcl.emitting = true
	if hp == 2:
		hat_lost = true
		hat_off_ptcl.emitting = true
		anim_hat.play("Hat_Hidden")
	elif hp == 1:
		madness.visible = true
		sfx_mad.play()
		
	

func set_hp( new_hp ):
	emit_signal("OnHp_changed",new_hp)
	hp = new_hp
	print(hp)
	if hp <= 0:
		die()

func die():
	sfx_death.play()
	emit_signal("OnDied")
	print("Murio")
	# queue_free() # Documentation: Queues this node to be deleted at the end of the current frame. When deleted, all of its children are deleted as well, and all references to the node and its children become invalid..

func was_attacked():
	return canBeAttacked

func _on_timer_attacked_timeout():
	canBeAttacked = true
	modulate.a = 1
