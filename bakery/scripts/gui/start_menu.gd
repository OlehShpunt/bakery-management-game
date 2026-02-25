extends Control

@onready var join_name = $Panel/JoinName
@onready var host_name = $Panel/HostName
@onready var debug = $Panel/debug


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_join_button_pressed() -> void:
	var input_name = join_name.text.strip_edges()
	
	if input_name.is_empty():
		debug.text = "{NETWORK_SETUP} Enter a name before joining!"
		print("{NETWORK_SETUP} Enter a name before joining!")
		return
	
	# Set player info before joining
	network_setup.player_info["name"] = input_name
	
	# Join game (default to localhost for now)
	var err = network_setup.join_game()
	if err != OK:
		debug.text = "{NETWORK_SETUP} Failed to connect: " + str(err)
		print("{NETWORK_SETUP} Failed to connect: ", err)
	else:
		debug.text = "{NETWORK_SETUP} Connecting to server as: " + str(input_name)
		print("{NETWORK_SETUP} Connecting to server as: ", input_name)


func _on_host_button_pressed() -> void:
	var input_name = host_name.text.strip_edges()
	
	if input_name.is_empty():
		debug.text = "{NETWORK_SETUP} Enter a name before hosting!"
		print("{NETWORK_SETUP} Enter a name before hosting!")
		return
	
	# Set player info before hosting
	network_setup.player_info["name"] = input_name
	
	# Create the server
	var err = network_setup.create_game()
	if err != OK:
		debug.text = "{NETWORK_SETUP} Failed to host: " + str(err)
		print("{NETWORK_SETUP} Failed to host: ", err)
	else:
		debug.text = "{NETWORK_SETUP} Hosting server as: " + str(input_name)
		print("{NETWORK_SETUP} Hosting server as: ", input_name)
		


## SERVER ONLY
func _on_load_game_button_pressed() -> void:
	
	#If Server
	if multiplayer.get_unique_id() == 1:
		if (player_location_lists.num_of_players() > 0):
			debug.text = "[SERVER] Loading game..."
			print("[SERVER] Loading game...")
			network_setup.load_game.rpc(path_holder.STREET_PATH)
			GameOrchestrator.start_game_processes()
		else: 
			debug.text = "[SERVER] Cannot load the game, because player list is empty"
			print("[SERVER] Cannot load the game, because player list is empty")
	
	# If Client
	else:
		debug.text = "Unknown error: Clients cannot load game"
		push_warning("Unknown error: Clients cannot load game")

#
#func _on_join_name_gui_input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch and event.pressed:
		#$Panel/JoinName.grab_focus()
#
#
#func _on_host_name_gui_input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch and event.pressed:
		#$Panel/HostName.grab_focus()
#
#
#func _on_join_button_gui_input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch and event.pressed:
		#$Panel/JoinButton.
#
#
#func _on_host_button_gui_input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch and event.pressed:
		#$Panel/HostButton.emit_signal("pressed")
#
#
#func _on_load_game_button_gui_input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch and event.pressed:
		#$Panel/LoadGameButton.emit_signal("pressed")
