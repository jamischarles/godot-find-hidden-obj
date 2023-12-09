extends Control




# spinner ticks
func _on_timer_timeout():
	var spinner = $spinner_img
	
	#if spinner.rotation >= 100:
	spinner.rotation += 7
	#else:
		#spinner.value += 5
		
