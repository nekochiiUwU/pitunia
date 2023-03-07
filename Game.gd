extends Node


func _ready():
	var LocalPlayer = load("res://Player.tscn").instantiate()
	LocalPlayer.name = Network.ID
	%Players.add_child(LocalPlayer)
	print(Network.ID)
	var NetworkSyncronizer = load("res://Network Interface.tscn").instantiate()
	NetworkSyncronizer.name = "Network Syncronizer"
	add_child(NetworkSyncronizer)
