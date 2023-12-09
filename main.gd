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

## Purchase STATE MACHINE (simple?)
var purchase_state = {
	
}

## state machine - default starting state
var local_state = {
	status = 'purchase_LOCKED'
}

# add purchases LOCKED
# add purchases UNLOCKED

# because IF In unlocked state, you can't go to the purchase states. You can only go to clear (from my hacky thing)
# which we'll only allow in debug mode anyway... YASSSS.
# LOVE THIS

# after purchase completes, then we switch to locked or unlocked state
# with a possible message (with timer). which then auto switches the state to message on/off. YAS

#(becuase those really are states)
# maybe onload we switch from the default state if it's unlocked...

## if not handled stay in the current state...
## Q: TODO: Need a better way to handle the transition actions...
## For the purposes of this it doesn't matter if it's a new purchase or a restore
## do we need enter / exit / transition?
func transition_state(state, event):
	match state.status:
		## TODO: replace with purchase: (un-)locked
		'purchase_LOCKED': # bad name, but there's no purchase in progress. Default
			if event.type == "action" && event.action == "purchase_start":
				# switchState. TODO: Make separate fn for switching state?
				# TODO: Try out FSM. Finite state machines with xstate...
				state.status = "loading"
				# hidden button and show spinner
				showModal({type="loading"})
				#get_node('%unlock_button').visible = false
				#get_node('%spinner').visible = true
				# TODO: move the spinner?
			
			
				
		'purchase_UN_LOCKED':
			#showModal({})
			# there's not really any events we need to process here. It's stuck in that state
			pass
				
			
		'loading':
			
			## TODO: we need to measure success / failure of the action so we can decide here what to do
			## TODO: make this a match...?
			
			if event.type == "api_result" && (event.result == "purchase_success" || event.result == "restore_success"):
				# refresh page with unlocked state
				state.status = "purchase_UN_LOCKED"
				Global.set_state({all_levels_unlocked = true}) #dumb but this is app wide state
				showModal({type = "success" })
				# then wait x seconds before refreshing...
				await get_tree().create_timer(4).timeout
				
				## TODO: Tie ok to 
				## refresh
				get_tree().reload_current_scene()
				
				
			# TODO: listen for failure
			if event.type == "api_result" && (event.result == "purchase_failure" || event.result == "restore_failure"):
				print('FAILED')
				state.status = "purchase_LOCKED"
				showModal({type = "failure" })
				# then wait x seconds before refreshing...
				await get_tree().create_timer(5).timeout
				
				## refresh
				get_tree().reload_current_scene()
			# when event comes in during loading state we can show the message and undo the loading state
			# during what states do we want to support showing a message? All?
			# I suppose that can be a config or something?
			#match event.
			
			
			
		# DONE isn't a state. it's a event type in the loading state to

## with state
func showModal(state):
	var modal : AcceptDialog = get_node("modal_notification")
	#$modal_notification
	## Do I need to make the parent visible? A: yes
	
	# hide all the messages
	$modal_notification/PanelContainer/loading.visible = false
	$modal_notification/PanelContainer/success.visible = false
	$modal_notification/PanelContainer/failure.visible = false
	
	# hide buttons
	modal.get_ok_button().visible = false
	
	match state.type:
		"loading":
			$modal_notification/PanelContainer/loading.visible = true
		"success":
			#modal.get_ok_button().visible = true
			#$modal_notification/PanelContainer/success/Title/bg.custom_minimum_size.x = 950
			$modal_notification/PanelContainer/success.visible = true	
			
		"failure":
			#modal.get_ok_button().visible = true
			$modal_notification/PanelContainer/failure.visible = true	
			
	# unhide the modal
	$modal_notification.visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	print('Global: ', Global["state"])
	is_all_levels_unlocked = Global.state.all_levels_unlocked

	
	if is_all_levels_unlocked:
		# is this a violation? Or acceptable because it's really just setting initial state?
		local_state.status = "purchase_UN_LOCKED"
		#transition_state(local_state, {type = "unlock", value = "true"})
#	is_all_levels_unlocked = true # for testing

	# assert TODO: Wrap this in editor checks
	var levelImageButtons: Array[Node] = get_node("%free_levels").get_children()
	var last_level_button_name = levelImageButtons[-2].name # account for "more"
#	assert(last_level_button_name == Global.highest_level, "Level count mismatch. Please update 'highest_level' in global.gd to match number of levels in main.tscn")
	
	
	get_node("%unlock_button").connect('button_down', make_iap_purchase_request)
	get_node("%restore_button").connect('button_down', make_iap_restore_request)
	get_node("%clear_purchase").connect('button_down', clear_iap_purchase)
	
	

	
		
		
		# do we even need this? Do we need to store this?
		
		
	# if all levels haven't been unlocked yet, do an app store product id lookup
	if !is_all_levels_unlocked:
		make_iap_product_info_request()
		
	
	
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
		
		# remove lock icon and shape
		for child in lvl_button.get_children():
			lvl_button.remove_child(child) 
			
		free_level_parent.add_child(lvl_button)
		
	


func on_lvl_select_button_down():	
	startScrollPos = $ScrollContainer.scroll_vertical
	
	
func notify_user(data):
	print("notify: data", data)
	#then delay before refresh...? can be in payload

func check_appstore_purchase_events():
	while _appstore.get_pending_event_count() > 0:
		var event = _appstore.pop_pending_event()
		
		
		if event.result == "error" || event.result == "unhandled":
			print("####IAP PROBLEM:", event)
			transition_state(local_state, {type="api_result", result = "purchase_failure"})
		
		if event.result=="ok": # other possible values are "progress", "error", "unhandled", "completed"
			print("####EVENT", event)
			
			## TODO: Check offline ->
		# print(event.product_id)
			match event.type:
				'product_info':
					print("PORDUCT INFO: ", event)
			# fields: titles, descriptions, prices, ids, localized_prices, currency_codes, invalid_ids
#			...
				'purchase':
					if event.product_id == "matchy_match_unlock_001":
						# TODO: Messaging. Success (checkmark)
						transition_state(local_state, {type="api_result", result = "purchase_success"})
						#on_purchase_success()
						print('PURCHASE MATCH', event)
					else:
						print('PURCHASE NOT MATCH ', event)
						transition_state(local_state, {type="api_result", result = "purchase_failure"})

						#on_purchase_success()
					# what kind of validation do we need here?
					
#			# fields: product_id, transaction_id, receipt		
#					...
				'restore':
					print('RESTORE ', event)
					# this will restore ALL purchases. We need to verify the right one is there...
					if event.product_id == "matchy_match_unlock_001":
						# TODO: Messaging. Successfully restored
						transition_state(local_state, {type="api_result", result = "restore_success"})
						#on_purchase_success()
						
					else:
						print("NOT restored: ", event)
						transition_state(local_state, {type="api_result", result = "restore_failure"})
#					Q: Is this where we print an error?
#					# fields: product_id, transaction_id, receipt
#					...

				## TODO: Move this one layer higher?
				'completed':
					print('COMPLETED ', event)
					# TODO: Messaging. Popup: No purchases to restore. Sorry!!!
					transition_state(local_state, {type="api_result", result = "restore_failure", msg = "no purchases to restore"})
					
					# Now the last in-app purchase restore has been sent,
					# so if you didn't get any, the user doesn't have
					# any purchases to restore.
#					is_all_levels_unlocked = false
#					persistState({all_levels_unlocked = false})
					
					

#func on_purchase_success():
	

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
		
		## Use the state machine for this...
		transition_state(local_state, {type = "action", action = "purchase_start"})
		await get_tree().create_timer(4).timeout
		transition_state(local_state, {type = "api_result", result = "purchase_success"})

		
		#var newState = Global.set_state({all_levels_unlocked = true})
		#get_tree().reload_current_scene()
	
	
	if !is_IAP_available(): 
		print('NO IAP on this platform: Aborting purchase request.')
		## Todo: figure out how to polyfill this later with storekit 2
		return
	
	print('ATTEMPT PURCHASE')
	
	var result = _appstore.purchase({'product_id': "matchy_match_unlock_001"})
	if result == OK:
		# FIXME: Make this part testable on desktop from editor...
		print("Successfully started purchase request")
		_appstore.set_auto_finish_transaction(true)

		# show loading spinner
		transition_state(local_state, {type="action", action="purchase_start"})
		
		var timer = Timer.new()
		timer.wait_time = 1
		timer.connect("timeout", check_appstore_purchase_events)
		add_child(timer)
		timer.start()
	else:
		print("failed purchase request:", result)

func make_iap_restore_request():
	if is_running_from_editor():
		print('Bypassing IAP for on-mac editor')
		
		## Use the state machine for this...
		transition_state(local_state, {type = "action", action = "purchase_start"})
		await get_tree().create_timer(4).timeout
		transition_state(local_state, {type = "api_result", result = "purchase_success"})
	
	if !is_IAP_available(): 
		print('NO IAP on this platform: Aborting restore request')
		return
	
	print('ATTEMPT RESTORE')
	var result = _appstore.restore_purchases()
	if result == OK:
		print("Successfully started restore request")
		_appstore.set_auto_finish_transaction(true)
		
		transition_state(local_state, {type="action", action="purchase_start"})

		var timer = Timer.new()
		timer.wait_time = 1
		timer.connect("timeout", check_appstore_purchase_events)
		add_child(timer)
		timer.start()
	else:
		print("failed RESTORE request: ", result)

## Not sure why we have to look up the product info first in order to purchase it...
func make_iap_product_info_request():
	if Engine.has_singleton("InAppStore"):
		_appstore = Engine.get_singleton('InAppStore')
		var result = _appstore.request_product_info( { "product_ids": ["matchy_match_unlock_001"] } )

	#		var result = _appstore.purchase({'product_id': "1001"})
		print('#RESULT product result', result)

		if result == OK:
			print("Successfully started product info request")
			# set LOADING state...
			# show SPINNER HERE
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
	
	#print('###ENV', OS.get_name())
	
	## Doesn't seem to work...
	## Does it show this when it's running from xcode?
	print("OS.has_feature(\"standalone\")", OS.has_feature("standalone"))
	print("OS.get_name(\"macos\")", OS.get_name())
	return OS.get_name() == 'macOS'
	
#	return !OS.has_feature("standalone")
