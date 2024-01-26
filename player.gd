extends CharacterBody3D

@export var PLAYER_NUMBER = 1
@export var SPEED = 5.0
@export var DASH_LENGTH = 2.5
@export var PLAYER_COLOR = Color("green")

@onready var marker_3d = $Marker3D
@onready var sprite_3d = $Sprite3D

var direction
var can_dash = true
var dash_destination

func _ready():
	sprite_3d.modulate = PLAYER_COLOR

func _physics_process(delta):
	## input handling
	var movement_direction = Input.get_vector("left_" + str(PLAYER_NUMBER), "right_" + str(PLAYER_NUMBER), "up_" + str(PLAYER_NUMBER), "down_" + str(PLAYER_NUMBER))
	var aim_direction = Input.get_vector("aim_left_" + str(PLAYER_NUMBER), "aim_right_" + str(PLAYER_NUMBER), "aim_up_" + str(PLAYER_NUMBER), "aim_down_" + str(PLAYER_NUMBER))

	direction = (transform.basis * Vector3(movement_direction.x, 0, movement_direction.y)).normalized()
	var aim = (transform.basis * Vector3(aim_direction.x, 0, aim_direction.y)).normalized()
	if dash_destination:
		velocity.x = move_toward(dash_destination.x, DASH_LENGTH, 0)
		velocity.z = move_toward(dash_destination.z, DASH_LENGTH, 0)
		if position.distance_to(dash_destination) <= 0:
			print_debug("reset dash location")
			dash_destination = null
	elif direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if aim:
		marker_3d.position = aim_direction

	move_and_slide()

func _input(event):
	if event.is_action_pressed("dash_" + str(PLAYER_NUMBER)):
		dash()

func dash():
	if direction && can_dash:
		can_dash = false
		dash_destination = direction * DASH_LENGTH

func _on_timer_timeout():
	can_dash = true
