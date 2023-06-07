extends Node


func _ready():
	for name in ["{a29b0132-456e-11ed-8629-806e6f6e6963}", Network.ID]:
		var LocalPlayer = load("res://Player.tscn").instantiate()
		LocalPlayer.name = name
		%Players.add_child(LocalPlayer)
		print(name)
	for _i in range(1):
		var l = [Network.TYPE_GETTER, Network.TYPE_SETTER]
		for i in range(len(l)):
			var NetworkSyncronizer = load("res://Network Interface.tscn").instantiate()
			NetworkSyncronizer.type = l[i]
			NetworkSyncronizer.name = "Network Syncronizer"
			add_child(NetworkSyncronizer)

