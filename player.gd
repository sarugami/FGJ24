extends CharacterBody3D

@export var PLAYER_NUMBER = 1
@export var SPEED = 5.0
@export var FRICTION = 1.5
@export var BOUNCE_SPEED = 10
@export var DASH_LENGTH = 2.5
@export var DASH_SPEED = 25
@export var PLAYER_COLOR_BASE = Color("green")
@export var PLAYER_COLOR_DARK = Color("green")
@export var PLAYER_COLOR_HIGHLIGHT = Color("green")

@onready var dash_timer = $DashTimer
@onready var bonk_cherge_timer = $BonkChargeTimer
@onready var bonk_effect_timer = $BonkEffectTimer
@onready var marker_3d = $AttackArea/Marker3D
@onready var attackArea = $AttackArea
@onready var attackAreaCollider = $AttackArea/Marker3D/Area3D/CollisionShape3D
@onready var csg_cylinder_3d = $AttackArea/Marker3D/Area3D/CSGCylinder3D
@onready var sprites = $Sprites



var direction
var can_dash = true
var dash_destination
var dash_starting_point

func _ready():
	#sprite_3d.modulate = PLAYER_COLOR
	(sprites.find_child("Body") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("LegR") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("EarR") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("Nose") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("LegL") as Sprite3D).modulate = PLAYER_COLOR_DARK
	(sprites.find_child("EarL") as Sprite3D).modulate = PLAYER_COLOR_DARK
	(sprites.find_child("Decal") as Sprite3D).modulate = PLAYER_COLOR_HIGHLIGHT
	(sprites.find_child("Mouth") as Sprite3D).modulate = Color("white")


func _physics_process(_delta):
	## input handling
	var movement_direction = Input.get_vector("left_" + str(PLAYER_NUMBER), "right_" + str(PLAYER_NUMBER), "up_" + str(PLAYER_NUMBER), "down_" + str(PLAYER_NUMBER))
	var aim_direction = Input.get_vector("aim_left_" + str(PLAYER_NUMBER), "aim_right_" + str(PLAYER_NUMBER), "aim_up_" + str(PLAYER_NUMBER), "aim_down_" + str(PLAYER_NUMBER))

	direction = (transform.basis * Vector3(movement_direction.x, 0, movement_direction.y)).normalized()
	var aim = (transform.basis * Vector3(aim_direction.x, 0, aim_direction.y)).normalized()
	if dash_destination:
		if position.distance_to(dash_starting_point) >= DASH_LENGTH:
			dash_destination = null
	elif direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
		velocity.z = move_toward(velocity.z, 0, FRICTION)
		
	if aim:
		attackArea.rotation.y = Vector2(aim_direction.x, aim_direction.y * -1).angle()

	if direction.x > 0:
		sprites.scale.x = -1
	elif direction.x < 0:
		sprites.scale.x = 1

	var collision_info = move_and_collide(velocity * _delta)
	if collision_info:
		var bounce_vector = velocity.bounce(collision_info.get_normal())
		#print_debug("Bounced at: " + str(bounce_vector))
		velocity = Vector3(clamp(bounce_vector.x, -BOUNCE_SPEED, BOUNCE_SPEED), 0, clamp(bounce_vector.z, -BOUNCE_SPEED, BOUNCE_SPEED))
		#for i in collision_info.get_collision_count:
			#if collision_info.get_collider(i).get

func _input(event):
	if event.is_action_pressed("dash_" + str(PLAYER_NUMBER)):
		dash()
	elif event.is_action_pressed("attack_" + str(PLAYER_NUMBER)):
		attack()
	elif event.is_action_released("attack_" + str(PLAYER_NUMBER)):
		cancelAttack()

func dash():
	if direction && can_dash:
		can_dash = false
		velocity.x += direction.x * DASH_SPEED
		velocity.z += direction.z * DASH_SPEED
		
		dash_starting_point = position
		dash_destination = direction * DASH_LENGTH
		dash_timer.start()

func attack():
	print_debug("start attack")
	bonk_cherge_timer.start()

func cancelAttack():
	print_debug("cancel attack")
	bonk_cherge_timer.stop()

func _on_bonk_charge_timer_timeout():
	print_debug("bonk")
	attackAreaCollider.disabled = false
	bonk_effect_timer.start()

func _on_dash_timer_timeout():
	can_dash = true


func _on_player_collision_area_area_entered(area):
	print_debug("Area collided: " + str(area.global_position))
	print_debug("Current position: " + str(position))
	velocity = (area.position - position) * BOUNCE_SPEED

func _on_player_collision_area_body_entered(body):
	if !dash_destination:
		print_debug(str(PLAYER_NUMBER) + " entered collider velocity: " + str(body.velocity))
		velocity = body.velocity


func _on_bonk_effect_timer_timeout():
	attackAreaCollider.disabled = true

