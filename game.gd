extends Node3D
@onready var player_1 = $Gronk
@onready var player_2 = $Bobbler
@onready var player_3 = $Plump
@onready var player_4 = $Yippee
@onready var players = [player_1, player_2, player_3, player_4]
@onready var boos : Object

const OVER_SCREEN = preload("res://endscore.tscn")

var alivePlayerCount = 4
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
	
	if alivePlayerCount > playersAlive.size():
		alivePlayerCount = playersAlive.size()
		#(boss.get_child("Animator") as AnimationPlayer).play("Boss_laugh")

	if playersAlive.size() <= 1 && !isGameEnd:
		#TODO: give hat and end round
		var endscreenInstance = OVER_SCREEN.instantiate()
		var winner = playersAlive[0].name
		#(playersAlive[0].get_child("VictoryPlayer") as AudioStreamPlayer).play()
		(endscreenInstance.find_child("Label") as Label).text = winner + " Wins!\nPress enter to restart"
		add_child(endscreenInstance)
		isGameEnd = true

func _input(event):
	if event.is_action_pressed("start") && isGameEnd:
		get_tree().reload_current_scene()
