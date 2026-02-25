extends StaticBody2D

var cooking_result_cell = preload("res://scenes/gui/cooking_result_cell.tscn").instantiate()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BakeryStorage.CANVAS_LAYER.add_child(cooking_result_cell)

	var data_holder: bakery_data = $BakeryStorage.get_storage_data_holder()
	data_holder.inventory_contents_changed.connect(_on_inventory_contents_changed)
	cooking_result_cell.button_pressed.connect(_on_cook_button_pressed)


func _physics_process(_delta: float) -> void:
	if $BakeryStorage.GRID_CONTAINER.visible == true:
		cooking_result_cell.show()
		cooking_result_cell.global_position = $BakeryStorage.GRID_CONTAINER.global_position + Vector2(450, -150)
	else:
		cooking_result_cell.hide()


func _on_inventory_contents_changed(_cell_id):
	var data_holder: bakery_data = $BakeryStorage.get_storage_data_holder()

	var data_dict = data_holder.get_inventory_dictionary()

	# Array of current items stored in the 7-cell cooking storage
	var array = []

	for key in data_dict:
		var item: String = data_dict[key]
		print("Cook > item = ", item)
		# res://scenes/food/ingredients/flour.tscn
		# res://scenes/food/ingredients/ >>> flour.tscn
		var substr_item: String = item.substr(30, -1)
		# [0] = flour [1] = tscn
		var sliced_item = substr_item.split(".")[0]
		print("Cook > sliced_item = ", sliced_item)

		if sliced_item:
			array.append(sliced_item)

	# Cooking recipes are of size 7 max
	var count = 7 - array.size()

	for i in range(count):
		array.append(path_holder.EMPTY)

	var item: String = RecipeManager.get_recipe_result(array)
	print("Cook > item after recipe calculation = ", item)

	var result: String = path_holder.EMPTY
	if item != path_holder.EMPTY:
		result = "res://scenes/food/ingredients/" + item + ".tscn"

	if result == path_holder.EMPTY:
		cooking_result_cell.set_button_texture(null)
		cooking_result_cell.set_item_scene_path(path_holder.EMPTY)
	else:
		var item_tscn: Sprite2D = load(result).instantiate()
		cooking_result_cell.set_button_texture(item_tscn.texture)
		cooking_result_cell.set_item_scene_path(item_tscn.get_scene_path())


func _on_cook_button_pressed(cooked_item_scene_path):
	var item_added = false

	for i in range(local_player_data.inventory_size):
		# Control variable
		if !item_added:
			# Prevent adding to cell if it's already taken by other item
			if local_player_data.get_inventory_item(i) == path_holder.EMPTY:
				# Adding cooked item to cell i
				print("Cook > Adding ", cooked_item_scene_path, " to player inventory cell i = ", i)
				local_player_data.set_inventory_item(i, cooked_item_scene_path)
				# Reset current selected cell to prevent unexpected behavior
				client_ui_data.set_current_active_cell_id(-1, -1, path_holder.EMPTY)

				item_added = true

				# Clean up all items in cooking station storage
				var data_holder: bakery_data = $BakeryStorage.get_storage_data_holder()
				for cell_index in range(7):
					data_holder.set_inventory_item(cell_index, path_holder.EMPTY)

				break
