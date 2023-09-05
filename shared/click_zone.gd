extends Node2D

@export var shape_name: String = ""
var shape_uid: int = -1 # don't export because the UI overrides this and we want to set it from code
# or just make it readonly in UI
signal click_shape_clicked


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


## Fixme: This will probably be replace with collision detection when we draf the click target
func _on_input_event(viewport, event, shape_idx):
	# basic filtering to avoid sending ALL events through
	if event is InputEvent:
		if event.is_pressed():
#			print("event", event)
#			print('#### shape# ', shape_idx)
#			print('instandce_id', get_instance_id())
#			print("shape_id", shape_id)
			#print('SKUNK')
			# send the unique instance id along
			emit_signal("click_shape_clicked", shape_name, self)
			
	pass # Replace with function body.
