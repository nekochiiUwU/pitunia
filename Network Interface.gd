extends HTTPRequest

var request_action: Callable = func x():pass
var requesting:            String = ""
var request_buffer:         Array = []
var send_time:              float = 0.
var online_delay:           float = 0.
var type:                     int = 0
var mid_online_delay:       Array = [0, 0, 0]


func _ready():
	connect("request_completed", _request_completed)
	use_threads = true


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		type = !type
	if type == Network.TYPE_SYNCHONIZER:
		if requesting == "":
			sync()
		if mid_online_delay[2] >= 2:
			mid_online_delay[0] *= 1/mid_online_delay[2] * 1000
			mid_online_delay[1] *= 1/mid_online_delay[2] * 1000
			print("Sync: GET: ", int(mid_online_delay[0]                      ), 
				" ms\t\t SET: ", int(                      mid_online_delay[1]), 
				" ms\t\t ALL: ", int(mid_online_delay[0] + mid_online_delay[1]), 
				" ms")
			mid_online_delay = [0, 0, 0]


func sync():
	var request_content = recursive_automatic_online_variable_getter(get_node("../%Players").get_node(Network.ID))
	new_request("set", 1, request_content)
	# print("SET: ", request_content)
	request_action = func f(_d):
		mid_online_delay[1] += online_delay
		new_request("get", 1, {})
		request_action = func f(data):
			# print("GET: ", data)
			mid_online_delay[0] += online_delay
			mid_online_delay[2] += 1
			recursive_automatic_online_variable_assignment(data)


func convert_vectors(data):
	var value_list
	if data is Dictionary:
		value_list = data.values()
	else:
		value_list = data
	for element in value_list:
		if element is Array or element is Dictionary:
			convert_vectors(element)
		elif element is String:
			if element[0] == "(" and element[-1] == ")":
				var vector_type = 1
				for character in element:
					vector_type += int(character == ",")
				element = "Vector" + str(vector_type) + element
				element = str_to_var(element)


func recursive_automatic_online_variable_getter(current_path: Object) -> Dictionary:
	var online_variables: Dictionary = {}
	for node in current_path.get_children():
		online_variables.merge(recursive_automatic_online_variable_getter(node))
	if "online" in current_path:
		var key: String = current_path.get_path()
		key = key.substr(len("/root/"))
		online_variables[key] = current_path.online
	return online_variables


func _request_completed(result: int, response: int, headers: PackedStringArray, body):
	requesting = ""
	online_delay = Tools.time - send_time
	if !result:
		body = body.get_string_from_utf8()
		if body:
			if body[0] == "{":
				var json = JSON.new()
				json.parse(body)
				body = json.get_data()
				convert_vectors(body)
		if request_action.get_bound_arguments_count() != 1:
			request_action.call(body)
			request_action.bind(func x():pass)
	else:
		print("ERROR: ", result)
		print(headers)
		print(response)
	return 0


func recursive_automatic_online_variable_assignment(data: Dictionary, current_path = get_node("/root/")):
	for element_name in data.keys():
		if element_name is Dictionary:
			for node in current_path.get_children():
				if element_name == node.name:
					return recursive_automatic_online_variable_assignment(data[element_name], node)
		current_path.set(element_name, data[element_name])
		return 0


func new_request(request_type: String, game: int = 0, data: Dictionary = {}, password: String = "0"):
	var request_content: Dictionary = {
		"head": {"request": request_type, "game": str(game), "password": password}
	}
	for key in data.keys():
		request_content[key] = data[key]
	var request_headers: PackedStringArray = [
		"Content-Type: application/json", 
		"content-length: " + str(JSON.stringify(request_content).length())
	]
	requesting = request_type
	send_time = Tools.time
	return request(Network.SERVER, request_headers, HTTPClient.METHOD_POST, JSON.stringify(request_content))
