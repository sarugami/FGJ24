extends CharacterBody3D

@export var PLAYER_NUMBER = 1
@export var SPEED = 5.0
@export var PLAYER_COLOR = Color("green")

@onready var marker_3d = $Marker3D
@onready var sprite_3d = $Sprite3D

func _ready():
	sprite_3d.modulate = PLAYER_COLOR

func _physics_process(delta):
	var movement_direction = Input.get_vector("left_" + str(PLAYER_NUMBER), "right_" + str(PLAYER_NUMBER), "up_" + str(PLAYER_NUMBER), "down_" + str(PLAYER_NUMBER))
	var aim_direction = Input.get_vector("aim_left_" + str(PLAYER_NUMBER), "aim_right_" + str(PLAYER_NUMBER), "aim_up_" + str(PLAYER_NUMBER), "aim_down_" + str(PLAYER_NUMBER))
	var direction = (transform.basis * Vector3(movement_direction.x, 0, movement_direction.y)).normalized()
	var aim = (transform.basis * Vector3(aim_direction.x, 0, aim_direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if aim:
		marker_3d.position = aim_direction

	move_and_slide()
