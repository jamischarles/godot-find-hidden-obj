extends Node


func _ready():
	var modal : AcceptDialog = get_node('%modal_notification')
	
	# hide ok button depending on modal state...
	modal.get_ok_button().visible = false
	
func _physics_process(delta):
	$PanelContainer/loading/spinner_container/spinner_img.rotate(7 * delta)

## Ok button pressed
func _on_modal_notification_confirmed():
	## refresh
	get_tree().reload_current_scene()
	#pass # Replace with function body.
