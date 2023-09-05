extends Node2D

# Q: should the scene manager live here? Or someplace else?
# just make it work!!


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_up():
	get_tree().change_scene_to_file("res://level_selector.tscn")
