## This class contains static methods that control, spawn, manage
## entities, events, classes. Does not control game flow.
class_name GameController extends Node


const BUYING_PHASE = "Buying Phase"
const PREPARATION_PHASE = "Preparation Phase"
const SELLING_PHASE = "Selling Phase"


##-----------------------------------------------
## Main game loop
##-----------------------------------------------


## Triggers the start of Buying Phase during which
## players purchase the necessary items, products and services
static func triggerBuyingPhase(duration: int):
	
	# Update phase name
	GameLoopUi.change_phase(BUYING_PHASE)
	
	# Reset timer
	GameLoopUi.assign_new_timer(duration)
	
	# Generate and assign Seller item list
	seller_item_list_generator.generate_item_list_for_all_sellers()
	
	# Remove all NPCs from registers
	for child in npc_driver.get_children():
		if child.has_method("npc"):
			child.queue_free()  # TODO replace with a method call that makes NPCs leave the locations instead of disappearing like now
	
	# Unblock Sellers
	# (Sellers' tradeable components check at runtime for the buying phase)
	
	# Teleport all players in front of their bakeries
	# TODO

## Triggers the start of Preparation Phase during which
## players bake products, manage inventory and prepare for the Selling Phase
static func triggerPreparationPhase(duration: int, round_num: int):
	
	# Update phase name
	GameLoopUi.change_phase(PREPARATION_PHASE)
	
	# Reset timer
	GameLoopUi.assign_new_timer(duration)  # TODO Consider increasing the duration as round_num goes up
	
	# Block Sellers
	# (Sellers' tradeable components check at runtime for the buying phase)
	
	# Teleport all players to their bakeries
	# TODO


## Triggers the start of Buying phase during which
## players purchase the necessary items, products and services
static func triggerSellingPhase(duration: int, round_num: int):
	
	# Update phase name
	GameLoopUi.change_phase(SELLING_PHASE)
	
	# Reset timer
	GameLoopUi.assign_new_timer(duration)
	
	# Spawn NPCs
	npc_driver.add_npc_base(round_num, 3)  # TEST  # TODO rework number of NPCs and change method

static func startNewRound(round_num: int):
	pass


##-----------------------------------------------
## Entities
##-----------------------------------------------
