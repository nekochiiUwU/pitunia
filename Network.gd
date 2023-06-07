extends Node

var ID:            String = OS.get_unique_id()
var SERVER:        String = "http://tremisabdoul.go.yj.fr/game/main.php"
var TYPE_MANUAL:      int = 0 # Default network interface status
var TYPE_SYNCHONIZER: int = 1
var TYPE_SETTER:      int = 2
var TYPE_GETTER:      int = 3

func is_master(player):
	return player.name == ID
