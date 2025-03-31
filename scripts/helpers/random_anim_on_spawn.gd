extends AnimatedSprite2D

func _ready() -> void:
	#print_debug("Calling ready on random_anim spritesheet")
	pick_random_animation()

## Picks a random animation from our list and plays it.
func pick_random_animation() -> void:
	var animation_names = sprite_frames.get_animation_names()
	animation = animation_names[randi_range(0, animation_names.size() - 1)] # Picks a random animation from 0-size()-1 and assigns it.
	play()
	#print_debug("Playing " + animation)
