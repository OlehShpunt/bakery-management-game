class_name npc_base
extends Node2D

@onready var npc_body_collision_area = $NPCBodyCollisionArea2D

@export var movement_speed: float = 20.0

@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var thoughts = $ThoughtComponent
@onready var button = $Button

var movement_delta: float
## Used on instance creation before adding to a scene to specify initial NPC spawn position
var buffered_target_position : Vector2 = Vector2.ZERO
@onready var npc_current_location_path = path_holder.STREET_PATH

## Item paths of all visible to npc item holders
var visible_items = []
## Items that NPC initially planned to buy in current round. Not necessarily NPC will be able to buy these items.
var planned_purchase_list = []
## Items that the NPC is willing to buy in current bakery
## Intersection of visible_items and planned_purchase_list
var desired_items = []

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	if buffered_target_position != Vector2.ZERO:
		navigation_agent.target_position = buffered_target_position
	else:
		push_warning("buffered_target_position is ZERO")
	
	player_location_lists.locations_changes.connect(on_player_location_changed)
	
	thoughts.display(desired_items)


func _process(delta: float) -> void:
	pass


func _physics_process(delta):
	
	print("()() ", global_position)
	
	# Do not move if navigation map is not synchronized or is empty
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	# Do not move if no more path points, e.g. finished
	if navigation_agent.is_navigation_finished():
		print("*** finished")
		# Teleport logic
		var teleport_to_path = global_ref_register.teleport_vector2_to_location_path(navigation_agent.target_position)
		if teleport_to_path != path_holder.EMPTY:
			print("*** setting npc_current_location_path to new value: ", teleport_to_path)
			navigation_agent.velocity = Vector2.ZERO
			set_npc_current_location_path(teleport_to_path)
		else:
			print("*** not setting npc_current_location_path to new value because teleport_to_path is empty")
		return
	
	print("*** not finished with target at ", navigation_agent.target_position)
	
## TODO it is still moving towards the set target position and aint moving when current location is not street
	movement_delta = movement_speed * delta
	var next_path_position : Vector2 = navigation_agent.get_next_path_position()
	var new_velocity : Vector2 = global_position.direction_to(next_path_position) * movement_delta
	
	# If avoidance enabled, entrust velocity to the built-in avoidance system
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	# If not, calculate velocity manually
	else:
		_on_velocity_computed(new_velocity)


## Manually computes velocity
func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)


## Set new target to move towards
func set_target_position(new_target_position: Vector2):
	navigation_agent.set_target_position(new_target_position)


## Called when the playern or self changes location
## Hide or show self if in same location as player
func on_player_location_changed(location_list):
	print("*** called on loc changed")
	
	# TODO lambda for deferred_call()
	
	call_deferred("deferred_call", location_list)
# TODO lambda
func deferred_call(location_list):
	var current_location_path : String = get_tree().current_scene.get_location_path()
	
	print("*** current_location_path = ", current_location_path)
	print("*** npc_current_location_path = ", npc_current_location_path)
	
	if location_list[npc_current_location_path].has(get_multiplayer_authority()):
		self.show()
		print("*** showing npc")
	else:
		self.hide()
		print("*** hiding npc")


## When entered teleport area, set npc_current_location to teleport's teleport_to value
# DEPRECATED
func _on_teleport_area_entered(teleport : Teleport) -> void:
	return
	
	print("*** teleport area entered")
	var teleport_to : String = teleport.get_teleport_to_path()
	self.set_npc_current_location_path(teleport_to)


func set_npc_current_location_path(new_path : String) -> void:
	global_position = spawnpoint_resolver.get_spawn_point(new_path, npc_current_location_path)
	npc_current_location_path = new_path
	
	if new_path == path_holder.STREET_PATH:
		for i in range(32):
			navigation_agent.set_navigation_layer_value(i, false)
		navigation_agent.set_navigation_layer_value(1, true)
	else:
		print("*** setting new target pos for test purposes")
		navigation_agent.target_position = global_position + Vector2(180, -85)  # TEST
		
		for i in range(32):
			navigation_agent.set_navigation_layer_value(i, false)
		navigation_agent.set_navigation_layer_value(2, true)
		
		### NPC looks through item holders
		#var t = Timer.new()
		#add_child(t)
		#await t.start(4)
		#navigation_agent.target_position = global_position + Vector2(100, 0)  # TEST
	
	on_player_location_changed(player_location_lists.get_locations())
	
	# Reset var that tracks how many item holders the npc has read
	if npc_current_location_path == path_holder.STREET_PATH:
		count = 0
		empty_visible_items()

# Track how many item holders the npc has read
var count = 0

func _on_item_holder_entered(area: Area2D) -> void:
	
	# There are 9 item holders, so if has already loaded all, don't anymore
	if count >= 9:
		return
	
	count += 1
	
	
	var item_holder: ItemHolder = area.get_parent()
	#var item_holder_id: int = item_holder.get_id()
	print("^^* item holder id: ", item_holder.get_id())
	
	var item_holder_dat : item_holder_data = item_holder.get_storage_data_holder()
	var item: String = item_holder_dat.get_inventory_item(0)
	
	print("^^* item holder entered - adding ", item)
	
	add_visible_item(item)


func add_visible_item(item: String) -> void:
	if item != path_holder.EMPTY:
		visible_items.push_back(item)
		display_thoughts(2)


func remove_visible_item(item: String) -> void:
	visible_items.erase(item)


func empty_visible_items() -> void:
	visible_items.resize(0)


func set_planned_purchase_list(list: Array):
	planned_purchase_list = list


func remove_from_purchase_list(item: String):
	planned_purchase_list.erase(item)
	display_thoughts()


## Calculates intersection of visible_items and planned_purchase_list,
## assigns it to desired_items and displays the desired_items
func display_thoughts(_delay: int = 0):
	print("(( displaying thoughts...")
	var to_display: Array = array_operations.intersection_of(visible_items, planned_purchase_list)
	desired_items = to_display
	print(visible_items, "(( intersect ", planned_purchase_list, " = ", to_display)
	thoughts.display(to_display, _delay)


func _on_button_pressed() -> void:
	print("(( button pressed")
	if not planned_purchase_list.is_empty():
		# If the active cell is in inventory
		if client_ui_data.get_current_active_cell_data_holder_id() == local_player_data.get_id():
			var cell_id = local_player_data.get_current_active_cell()
			var item_path = local_player_data.get_inventory_item(cell_id)
			
			print("(( item_path is ", item_path)
			if desired_items.has(item_path):
				
				# Purchase logic here (money)
				var profit: int = Finance.resolve_price(item_path)
				local_player_data.balance += profit  # TODO use setter method
				
				local_player_data.set_inventory_item(cell_id, path_holder.EMPTY)
				client_ui_data.set_current_active_cell_id(-1, -1, path_holder.EMPTY)
				# Remove purchased item from the desired and purchase list
				remove_from_purchase_list(item_path)
			else:
				print("(( the chosen item is not in the NPC desired list")
		else:
			print("(( current active cell is not in inventory")
	else:
		print("(( planned_purchase_list is empty")


## Identification method
func npc():
	pass


func _on_npc_detector_body_entered(body: Node2D) -> void:
	return
	if body.has_method("player"):
		return
		
	print("--& detected ", body)
	
	# For now just make NPC simply stop navigating
	navigation_agent.target_position = global_position


func _on_npc_detector_area_entered(area: Area2D) -> void:
	print("--& area detected: ", area)
	
	if (area == npc_body_collision_area):
		print("--& returning this area:  ", area)
		return
	
	# For now just make NPC simply stop navigating
	navigation_agent.target_position = global_position
