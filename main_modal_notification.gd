extends Node


func _ready():
	var modal : AcceptDialog = get_node('%modal_notification')
	
	# hide ok button depending on modal state...
	modal.get_ok_button().visible = false
	
	$PanelContainer/loading/close_btn.connect("button_up", close_modal)
	$PanelContainer/success/close_btn.connect("button_up", close_modal)
	$PanelContainer/failure/close_btn.connect("button_up", close_modal)
	
	$PanelContainer/loading/ok_btn.connect("button_up", reload_home_screen)
	$PanelContainer/success/ok_btn.connect("button_up", reload_home_screen)
	$PanelContainer/failure/ok_btn.connect("button_up", reload_home_screen)
	
func _physics_process(delta):
	$PanelContainer/loading/spinner_container/spinner_img.rotate(7 * delta)

## Ok button pressed
func _on_modal_notification_confirmed():
	## refresh
	get_tree().reload_current_scene()
	#pass # Replace with function body.
	
	
	
func close_modal():
	var modal: AcceptDialog = get_node('%modal_notification')
	modal.hide() # TODO: Send the "cancel" event with this? So we can stop api calls? Later... not now...
