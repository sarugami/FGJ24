extends Node3D


func play_idle_animation():
	%Animation.play("Idle")


func play_run_animation():
	%Animation.play("Run")

func play_attack_animation():
	%Animation.play("Attack")
