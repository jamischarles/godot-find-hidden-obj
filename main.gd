extends Node2D


## states to account for
## Get it working fugly, then polish once the most important pieces are in place.
## like setting up a painting... composition
## locked
## loading
## unlocked

## Todo: store unlocked state in file locally

var _appstore

# scroll pos when button press starts
var startScrollPos

var is_all_levels_unlocked

# Called when the node enters the scene tree for the first time.
func _ready():
	print('Global: ', Global["state"])
	is_all_levels_unlocked = Global.state.all_levels_unlocked
#	is_all_levels_unlocked = true # for testing

	# assert TODO: Wrap this in editor checks
	var levelImageButtons: Array[Node] = get_node("%free_levels").get_children()
	var last_level_button_name = levelImageButtons[-2].name # account for "more"
#	assert(last_level_button_name == Global.highest_level, "Level count mismatch. Please update 'highest_level' in global.gd to match number of levels in main.tscn")
	
	
	get_node("%unlock_button").connect('button_down', make_iap_purchase_request)
	get_node("%restore_button").connect('button_down', make_iap_restore_request)
	get_node("%clear_purchase").connect('button_down', clear_iap_purchase)
	
	
	### IAP CODE. TODO: move to separate function
	if Engine.has_singleton("InAppStore"):
		_appstore = Engine.get_singleton('InAppStore')
		
		
		# do we even need this? Do we need to store this?
		
		
		## TODO: only do this when we haven't purchased yet?
		
		var result = _appstore.request_product_info( { "product_ids": ["matchy_match_unlock_001"] } )


#		var result = _appstore.purchase({'product_id': "1001"})
		print('#RESULT product result', result)

		if result == OK:
			print("Successfully started product info request")
			# set LOADING state...
			_appstore.set_auto_finish_transaction(true)

			var timer = Timer.new()
			timer.wait_time = 1
			timer.connect("timeout", check_appstore_purchase_events)
			add_child(timer)
			timer.start()
		else:
			print("failed requesting product info")
	else:
		print("no app store plugin")
		print("##iOS IAP plugin is not available on this platform.")
	
	
	############# END IAP CODE
	
	
	
#
#	if Engine.has_singleton("InAppStore"):
#		in_app_store = Engine.get_singleton("InAppStore")
#		print("##IN APP STORE WORKS!!!!", in_app_store)
#	else:
#		print("##iOS IAP plugin is not available on this platform.")
	
	

	
	
	
	# if paid levels unlocked
	if is_all_levels_unlocked:
		# show all levels next to each other
		move_paid_levels_next_to_free()
		# hide the paid panel
		$ScrollContainer/VBoxContainer/level_container/PaidSectionPanel.visible = false

	
	
	# scrolling to a node. This works pretty well...
#	await get_tree().process_frame
#	$ScrollContainer.ensure_control_visible($ScrollContainer/VBoxContainer/MarginContainer/level_images/"02")
	
#	print('02??: ', get_level_button_node("02"))
#	scroll_to_level_img('02')


	if Global.next_level:
		scroll_to_level_img(Global.next_level)
	
	
	var buttons: Array[Node] = get_node("%free_levels").get_children()
	
	for i in len(buttons):
		var button = buttons[i]
		
		# if not a textureButton (like the "more" section) then just skip over it
		if button.get_class() != "TextureButton":
			continue
		
		print('button', button)
		button.connect('button_down', on_lvl_select_button_down)
		button.connect('button_up', on_lvl_select_button_up.bind(button.get_name()))
		
		if !is_all_levels_unlocked && i > 2:
			button.disabled = true ## TODO: Add disabled style
			button.modulate.a = .3
		
		
	# dynamically add the click events with the click params...
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func is_IAP_available() ->bool:
	return !!_appstore

	
## If levels are all unlocked, show them next to the free ones.
## FIXME: Consider copy instead of move? later...
func move_paid_levels_next_to_free():
	var free_level_parent = get_node("%free_levels")
	var paid_level_parent = get_node("%paid_levels")
	for lvl_button in paid_level_parent.find_children("*", "TextureButton"):
		paid_level_parent.remove_child(lvl_button) 
		free_level_parent.add_child(lvl_button)
		
	


func on_lvl_select_button_down():	
	startScrollPos = $ScrollContainer.scroll_vertical

func check_appstore_purchase_events():
	while _appstore.get_pending_event_count() > 0:
		var event = _appstore.pop_pending_event()
		if event.result=="ok": # other possible values are "progress", "error", "unhandled", "completed"
			print("####EVENT", event)
		# print(event.product_id)
			match event.type:
				'product_info':
					print("PORDUCT INFO: ", event)
			# fields: titles, descriptions, prices, ids, localized_prices, currency_codes, invalid_ids
#			...
				'purchase':
					if event.product_id == "matchy_match_unlock_001":
						on_purchase_success()
						print('PURCHASE MATCH', event)
					else:
						print('PURCHASE NOT MATCH ', event)
						on_purchase_success()
					# what kind of validation do we need here?
					
#			# fields: product_id, transaction_id, receipt		
#					...
				'restore':
					print('RESTORE ', event)
					# this will restore ALL purchases. We need to verify the right one is there...
					if event.product_id == "matchy_match_unlock_001":
						on_purchase_success()
					else:
						print("NOT restored: ", event)
#					# fields: product_id, transaction_id, receipt
#					...
				'completed':
					print('COMPLETED ', event)
					# Now the last in-app purchase restore has been sent,
					# so if you didn't get any, the user doesn't have
					# any purchases to restore.
#					is_all_levels_unlocked = false
#					persistState({all_levels_unlocked = false})
					# TODO: Messaging. Popup: No purchases to restore. Sorry!!!
					

func on_purchase_success():
	Global.set_state({all_levels_unlocked = true})
	get_tree().reload_current_scene()

# change scene to the clicked button
func on_lvl_select_button_up(level_to_load):
	print('UP', $ScrollContainer.scroll_vertical)
	var endScrollPos = $ScrollContainer.scroll_vertical
	
	# if we're scrolling, ignore the button click
	# abs() ensures the number is positive
	if abs(endScrollPos - startScrollPos) > $ScrollContainer.scroll_deadzone:
		return
	
	# am I scrolling? If yes. Ignore
	
	print('load_level: ', level_to_load)
	Global.change_scene(level_to_load)


# IAP functions ##################

## In local cache, clear the purchase.
func clear_iap_purchase():
	Global.set_state({all_levels_unlocked = false})
	get_tree().reload_current_scene()

func make_iap_purchase_request():
	# for editor debugging
	if is_running_from_editor():
		print('Bypassing IAP for on-mac editor')
		var newState = Global.set_state({all_levels_unlocked = true})
		get_tree().reload_current_scene()
	
	
	if !is_IAP_available(): 
		print('NO IAP on this platform: Aborting restore request')
		return
	
	print('ATTEMPT PURCHASE')
	
	var result = _appstore.purchase({'product_id': "matchy_match_unlock_001"})
	if result == OK:
		print("Successfully started purchase request")
		_appstore.set_auto_finish_transaction(true)

		var timer = Timer.new()
		timer.wait_time = 1
		timer.connect("timeout", check_appstore_purchase_events)
		add_child(timer)
		timer.start()
	else:
		print("failed purchase request:", result)

func make_iap_restore_request():
	if !is_IAP_available(): 
		print('NO IAP on this platform: Aborting restore request')
		return
	
	print('ATTEMPT RESTORE')
	var result = _appstore.restore_purchases()
	if result == OK:
		print("Successfully started restore request")
		_appstore.set_auto_finish_transaction(true)

		var timer = Timer.new()
		timer.wait_time = 1
		timer.connect("timeout", check_appstore_purchase_events)
		add_child(timer)
		timer.start()
	else:
		print("failed RESTORE request: ", result)


################# END IAP functions

func _on_play_button_up():
	scroll_to_level_img("01")
#	var tween = get_tree().create_tween().set_parallel(false)


#	tween.tween_property($ScrollContainer, "scroll_vertical", 1100, .9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(.01)
	
	
func get_level_button_node(levelNum: String) -> TextureButton:
	var levelImageButtons : Array[Node] = get_node("%free_levels").get_children()
	# only expect one result to match, so we'll return that
	var nextButtonToSelect = levelImageButtons.filter(func(node): return node.name == levelNum)
	if !nextButtonToSelect:
		return levelImageButtons[-1] # if none found return last one
	return nextButtonToSelect[0]
	
	
# animated scroll to the element
# needs to be string because it's left padded with zero
func scroll_to_level_img(levelNum: String):	
	var buffer = 100
	
	# get global Y position of the level img we want to scroll to, then add a little buffer
	var node: TextureButton = get_level_button_node(levelNum)
	
	
	await get_tree().process_frame # needed so physics can calc the real position
	
	var targetYPos =  node.get_global_rect().position.y
	
	var tween = get_tree().create_tween().set_parallel(false)
	tween.tween_property($ScrollContainer, "scroll_vertical", targetYPos - buffer, .9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(.01)


## HELPER FUNCTIONS ------------------

## Is this running from editor or standalone binary...?

func is_running_from_editor() -> bool:
	
	## Doesn't seem to work...
	## Does it show this when it's running from xcode?
	print("OS.has_feature(\"standalone\")", OS.has_feature("standalone"))
	print("OS.has_environment(\"macos\")", OS.has_environment("macos"))
	return OS.has_environment("macos")
	
#	return !OS.has_feature("standalone")
