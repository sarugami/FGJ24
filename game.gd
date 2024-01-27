extends Node3D
@onready var player_1 = $Player
@onready var player_2 = $Player2
@onready var player_3 = $Player3
@onready var player_4 = $Player4

var players = [player_1, player_2, player_3, player_4]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var playersAlive = []
	#for player in players:
		#if player.visible:
			#playersAlive.append(player)
	
	#if playersAlive.count <= 1:
		#TODO: give hat and end round
		#pass

