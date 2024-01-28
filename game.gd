extends Node3D
@onready var player_1 = $Gronk
@onready var player_2 = $Bobbler
@onready var player_3 = $Plump
@onready var player_4 = $Yippee
@onready var players = [player_1, player_2, player_3, player_4]

const OVER_SCREEN = preload("res://endscore.tscn")


var isGameEnd = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var playersAlive = []
	for player in players:
		if player.visible:
			playersAlive.append(player)
	
	if playersAlive.size() <= 1:
		#TODO: give hat and end round
		isGameEnd = true
		var endscreenInstance = OVER_SCREEN.instantiate()
		var winner = playersAlive[0].name
		(endscreenInstance.find_child("Label") as Label).text = "Winner is " + winner + " Press enter to restart"
		add_child(endscreenInstance)

func _input(event):
	if event.is_action_pressed("start") && isGameEnd:
		get_tree().reload_current_scene()
