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
@export var PLAYER_COLOR = Color("green")
@export var MAX_HEALTH = 100.0

@onready var dash_timer = $DashTimer
@onready var bonk_charge_timer = $BonkChargeTimer
@onready var bonk_effect_timer = $BonkEffectTimer
@onready var marker_3d = $AttackArea/Marker3D
@onready var attackArea = $AttackArea
@onready var attackAreaCollider = $AttackArea/Marker3D/Area3D/CollisionShape3D
@onready var sprites = $Sprites
@onready var aim_fill = $AttackArea/Marker3D/AimCircle/AimFill
@onready var aim_circle = $AttackArea/Marker3D/AimCircle
@onready var aim_direction = $AttackArea/AimDirection
@onready var aim_reticle = $AttackArea/Marker3D/AimReticle
@onready var health = $PlayerUi/Health


var direction
var can_dash = true
var dash_destination
var dash_starting_point
var bonk_ready = false
var movement_enabled = true
var charging_bonk = false
var currentHealth = MAX_HEALTH

func _ready():
	#sprite_3d.modulate = PLAYER_COLOR
	(sprites.find_child("Body") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("LegR") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("EarR") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("Nose") as Sprite3D).modulate = PLAYER_COLOR_BASE
	(sprites.find_child("LegL") as Sprite3D).modulate = PLAYER_COLOR_DARK
	(sprites.find_child("EarL") as Sprite3D).modulate = PLAYER_COLOR_DARK
	(sprites.find_child("Decal") as Sprite3D).modulate = PLAYER_COLOR_HIGHLIGHT
	aim_circle.modulate = PLAYER_COLOR
	aim_reticle.modulate = PLAYER_COLOR
	aim_direction.modulate = PLAYER_COLOR
	aim_fill.modulate = PLAYER_COLOR

func _process(delta):
	if !bonk_charge_timer.paused:
		aim_fill.scale = Vector3((bonk_charge_timer.wait_time - bonk_charge_timer.time_left) / bonk_charge_timer.wait_time, (bonk_charge_timer.wait_time - bonk_charge_timer.time_left) / bonk_charge_timer.wait_time, (bonk_charge_timer.wait_time - bonk_charge_timer.time_left) / bonk_charge_timer.wait_time)

	health.value = int((currentHealth / MAX_HEALTH) * 100)

	if currentHealth <= 0:
		visible = false
		set_process_mode(PROCESS_MODE_DISABLED) 

func _physics_process(_delta):
	## input handling
	var movement_direction = Input.get_vector("left_" + str(PLAYER_NUMBER), "right_" + str(PLAYER_NUMBER), "up_" + str(PLAYER_NUMBER), "down_" + str(PLAYER_NUMBER))
	var aim_direction = Input.get_vector("aim_left_" + str(PLAYER_NUMBER), "aim_right_" + str(PLAYER_NUMBER), "aim_up_" + str(PLAYER_NUMBER), "aim_down_" + str(PLAYER_NUMBER))

	direction = (transform.basis * Vector3(movement_direction.x, 0, movement_direction.y)).normalized()
	var aim = (transform.basis * Vector3(aim_direction.x, 0, aim_direction.y)).normalized()
	if dash_destination:
		if position.distance_to(dash_starting_point) >= DASH_LENGTH:
			dash_destination = null
	elif direction && movement_enabled:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
		velocity.z = move_toward(velocity.z, 0, FRICTION)
		
	if movement_enabled:
		if !velocity && (sprites.find_child("Animation") as AnimationPlayer).current_animation != "Idle":
			(sprites.find_child("Animation") as AnimationPlayer).play("Idle")
		elif velocity && (sprites.find_child("Animation") as AnimationPlayer).current_animation != "Run": 
			(sprites.find_child("Animation") as AnimationPlayer).play("Run")
	
	if aim:
		attackArea.rotation.y = Vector2(aim_direction.x, aim_direction.y * -1).angle()

	if direction.x > 0:
		sprites.scale.x = -1
	elif direction.x < 0:
		sprites.scale.x = 1

	var collision_info = move_and_collide(velocity * _delta)
	if collision_info:
		var angleVector = Vector2(collision_info.get_collider(0).position.x, collision_info.get_collider(0).position.z).direction_to(Vector2(position.x, position.z))
		velocity = Vector3(angleVector.x, 0, angleVector.y)
		dash_destination = null
		#movement_enabled = false
		#bonk_effect_timer.start()
		#var bounce_vector = velocity.bounce(collision_info.get_normal())
		#print_debug("Bounced at: " + str(bounce_vector))
		#velocity = Vector3(clamp(bounce_vector.x, -BOUNCE_SPEED, BOUNCE_SPEED), 0, clamp(bounce_vector.z, -BOUNCE_SPEED, BOUNCE_SPEED))
		#for i in collision_info.get_collision_count:
			#if collision_info.get_collider(i).get
	
	var space_state = get_world_3d().direct_space_state
	var origin = position
	var end = origin + Vector3(0, -5, 0)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		currentHealth -= 1

func _input(event):
	if event.is_action_pressed("dash_" + str(PLAYER_NUMBER)):
		dash()
	elif event.is_action_pressed("attack_" + str(PLAYER_NUMBER)):
		attack()
	elif event.is_action_released("attack_" + str(PLAYER_NUMBER)):
		stopAttack()

func dash():
	if direction && can_dash:
		can_dash = false
		velocity.x += direction.x * DASH_SPEED
		velocity.z += direction.z * DASH_SPEED
		
		dash_starting_point = position
		dash_destination = direction * DASH_LENGTH
		dash_timer.start()

func attack():
	bonk_charge_timer.start()
	aim_circle.visible = true
	bonk_ready = false

func stopAttack():
	if !bonk_ready: 
		bonk_charge_timer.stop()
		aim_circle.visible = false
	else:
		attackAreaCollider.disabled = false
		movement_enabled = false
		bonk_effect_timer.start()
		(sprites.find_child("Animation") as AnimationPlayer).play("Attack")

func _on_bonk_charge_timer_timeout():
	bonk_ready = true

func _on_dash_timer_timeout():
	can_dash = true

func _on_bonk_effect_timer_timeout():
	attackAreaCollider.disabled = true
	aim_circle.visible = false
	movement_enabled = true

func _on_stun_timer_timeout():
	movement_enabled = true

func _on_player_collision_area_area_entered(area):
	#print_debug("Area collided: " + str(area.global_position))
	#print_debug("Current position: " + str(position))
	var angleVector = Vector2(area.global_position.x, area.global_position.z).direction_to(Vector2(position.x, position.z))
	velocity = Vector3(angleVector.x * BOUNCE_SPEED, 0, angleVector.y * BOUNCE_SPEED)
	#print_debug("Bonk velocity: " + str(velocity))
	movement_enabled = false
	currentHealth -= 10

func _on_player_collision_area_body_entered(body):
	if !dash_destination:
		print_debug(str(PLAYER_NUMBER) + " entered collider velocity: " + str(body.velocity))
		#velocity = body.velocity
		if body.velocity.x > -1 && body.velocity.x < 1 && body.velocity.z > -1 && body.velocity.z < 1:
			var angleVector = Vector2(body.position.x, body.position.z).direction_to(Vector2(position.x, position.z))
			velocity = Vector3(angleVector.x * BOUNCE_SPEED, 0, angleVector.y * BOUNCE_SPEED)
