class_name CookingComponent
extends Node2D

@onready var cook = $Cook
@onready var cooking_gui = $Cook/CookingGUI
@onready var interactable_zone = $InteractableZone
var num_players_in_interactable_zone = 0
var mouse_is_hovering_cook = false
var cooking_gui_shown = false
# Basically the "shown" vars are not really needed in the if statements below (it's just for security).
# Those will be accessed by other scripts.
# IDK WHETHER I NEED THE if CHECKS using these
# variables - MAYBE show() WON"T RAISE ERROR WHEN THE GUI IS ALREADY SHOWN - dunno :/
var cook_shown = false # IGNORE AS A SEMANTIC IN IF STATEMENTS OF THIS SCRIPT


func _ready() -> void:
	cook.hide()
	cooking_gui.hide()


# When player enters the cooking zone, cook is enabled
func _on_interactable_zone_body_entered(body: Node2D) -> void:
	#print(body, " entered")
	if (body.has_method("player")):
		num_players_in_interactable_zone += 1
		if (!cook_shown): # Exception (lol what), there's where it's needed
			cook_shown = true
			cook.show()


# When all players exit the tradeable zone, trade (dollar) is disabled
func _on_interactable_zone_body_exited(body: Node2D) -> void:
	if (body.has_method("player")):
		num_players_in_interactable_zone -= 1
		if (cook_shown and num_players_in_interactable_zone <= 0):
			cook_shown = false
			cook.hide()


# Allows opening the seller gui hovering over cook
func _on_click_to_trade_mouse_entered() -> void:
	mouse_is_hovering_cook = true
	#print("mouse entered cook")


# Prevents the seller gui from opening when not hovering over cook
func _on_click_to_trade_mouse_exited() -> void:
	mouse_is_hovering_cook = false
	#print("mouse exited cook")


# Open/Close seller GUI here
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_is_hovering_cook:
		if not cooking_gui_shown:
			cooking_gui_shown = true
			cooking_gui.show()
		else:
			# Prevent other players to close gui when another user is potentially using the gui
			# Otherwise, other could just spam close the
			# seller GUI to prevent another player(s) from buyning items
			if (num_players_in_interactable_zone == 1):
				cooking_gui_shown = false
				cooking_gui.hide()
