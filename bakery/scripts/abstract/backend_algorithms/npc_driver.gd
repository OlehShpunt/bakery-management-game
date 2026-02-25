extends Node


var npc_customer_inst = preload("res://scenes/npc/npc_customer.tscn")
var npc_base_inst = preload("res://scenes/npc/npc_base.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Add a nav layer with no borders so that npc can move freely
	var empty_nav_reg = NavigationRegion2D.new()
	
	for i in range(32):
		empty_nav_reg.set_navigation_layer_value(i, false)
		
	empty_nav_reg.set_navigation_layer_value(2, true)
	
	# Create a big walkable polygon
	# TODO: custom for each location (shop/bakery) with different polygon assigned using a polygon resolver script
	var nav_polygon = NavigationPolygon.new()
	var polygon = PackedVector2Array([
		Vector2(-200, -200),
		Vector2(2000, -200),
		Vector2(2000, -2000),
		Vector2(-200, 2000)
	])
	nav_polygon.add_outline(polygon)
	nav_polygon.make_polygons_from_outlines()
	
	# Set the polygon to the region
	empty_nav_reg.navigation_polygon = nav_polygon
	
	add_child(empty_nav_reg)
	
	
	print("&& NPC Driver started! ")


func add_npc_base(round_num, quantity):
	
	for i in range(quantity):
		
		var purchase_list_for_this_round: Array = PurchaseListManager.get_list(round_num)
		
		var purchase_list_for_a_prev_round = []
		if round_num != 1:
			var rand_round_num = randi_range(1, round_num - 1)
			purchase_list_for_a_prev_round = PurchaseListManager.get_list(rand_round_num)
		else:
			purchase_list_for_a_prev_round = []
		
		var target_pos = global_ref_register.get_teleport_global_pos(str(101))
		
		var npc = npc_base_inst.instantiate()
		npc.buffered_target_position = target_pos
		npc.global_position = Vector2(1750, 1650)  # bottom
		#npc.global_position = Vector2(1726, 900)  # road cross
		
		var planned_purchase_list = purchase_list_for_this_round + purchase_list_for_a_prev_round
		npc.set_planned_purchase_list(planned_purchase_list)
		
		add_child(npc)
		
		await get_tree().create_timer(2).timeout


func add_npc_customer():
	var npc = npc_customer_inst.instantiate()
	
	npc.path = [
		global_ref_register.get_path_point_ref(20).get_rand_coordinate(),
		global_ref_register.get_path_point_ref(14).get_rand_coordinate(),
		global_ref_register.get_path_point_ref(7).get_rand_coordinate(),
		global_ref_register.get_path_point_ref(6).get_rand_coordinate(),
		global_ref_register.get_path_point_ref(1).get_rand_coordinate()
	]
	
	npc.global_position = npc.path[-1]
	
	add_child(npc)
