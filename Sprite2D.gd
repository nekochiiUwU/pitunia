extends Sprite2D

var online = {
	"position": position
}

func _physics_process(delta):
	if Network.is_master(get_node("../..")):
		position = get_global_mouse_position()
		online["position"] = position
