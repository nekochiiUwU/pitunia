extends Sprite2D

var online = {
	"position": position
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Network.is_master(get_node("../..")):
		position = get_global_mouse_position()
		online["position"] = position
