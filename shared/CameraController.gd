extends Camera2D


# can we listen for the scroll event in the scrollcontainer, then just follow that exactly?
#@onready var scrollContainer = get_tree().get_root().get_node("ScrollContainer")
@onready var scrollContainer: ScrollContainer = get_node("/root/Stage/HBoxContainer/MarginContainer/ScrollContainer")

# each cycle ensure the camera follows the scrollcontainer scroll position
func _process(delta):
	position.x = scrollContainer.get_h_scroll()
	position.y = scrollContainer.get_v_scroll()



