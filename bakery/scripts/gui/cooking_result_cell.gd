extends Control

@onready var TEXTURE_BUTTON = $Panel/TextureButton
@onready var item_scene_path: String = path_holder.EMPTY
signal button_pressed(item_scene_path)


func set_button_texture(t: Texture):
	TEXTURE_BUTTON.texture_normal = t


func set_item_scene_path(path: String):
	item_scene_path = path


func get_item_scene_path():
	return item_scene_path


func _on_texture_button_pressed() -> void:
	if item_scene_path == path_holder.EMPTY:
		return
	emit_signal("button_pressed", item_scene_path)
