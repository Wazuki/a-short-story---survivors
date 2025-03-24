## Every weapon that overrides [func _process] or [func _on_area_entered] MUST call the super for those first.
class_name  Weapon
extends Area2D


enum Type { SLAM, LIGHT_BLADE, WALDOS, ARROW, CHAIN_LIGHTNING}
enum TargetType { NONE, CLOSEST, HIGHEST_HP, RANDOM }

const Stat = CharacterStats.Stat # Assigns the CharacterStats enum for quick access.
const FRAME_UPDATE_OFFSET = 6
const ENEMY_CLEANUP_FRAME_OFFSET = 15

# Variables to keep track of what our closest targets are for that type of weapon.
var highest_hp_enemy_in_range: Enemy = null
var closest_enemy: Enemy = null

var enemies_in_range = {} ## An [int]-[Enemy] dictionary that tracks enemies in our colliders. Use [method get_instance_id()] to get the instance ID.

var weapon_type: Type
var description: String

var level: int
var damage: float
var speed: float
var cooldown: float

var crit_chance: float
var crit_mod: float

var cooldown_timer: Timer
var ready_to_fire: bool

var target_type = TargetType.NONE ## Determines the targeting logic for the weapon.

var first_level_up: bool = true:
	get:
		return first_level_up
	set(value):
		first_level_up = value
		if not first_level_up: create_cooldown_panel.emit() # Emit the signal only if we are now false - theoretically should only be called once?


var cooldown_panel
signal fire
signal critical_hit
signal create_cooldown_panel
signal begin_attack_sequence
signal gained_level(value)

const OVERHAUL_LEVEL = 7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the weapon timer programmatically.
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", _on_weapon_timer_timeout)
	
	# Connect the signal remove_enemy(enemy) to our remove_enemy function
	EnemyManager.remove_invalid_enemy.connect(remove_enemy)
	EnemyManager.cleanup.connect(cleanup_enemies)
	
	add_child(cooldown_timer)
	# cooldown_timer.wait_time = cooldown
	
	crit_chance = 0
	crit_mod = 0
	
	ready_to_fire = false

func level_up() -> void: gained_level.emit(level)

# Updates the target based on the targetting type. Requires any overriding derived classes to call super._process!()
func _process(_delta: float) -> void:
	if GameController.global_frame_count % FRAME_UPDATE_OFFSET == 0:
		if target_type == TargetType.CLOSEST: get_closest_target()
		elif target_type == TargetType.HIGHEST_HP: get_highest_hp_target()

	# Cleans up the enemies_in_range array every so often to clear out dead enemies. TODO - consider signals.
	if GameController.global_frame_count % ENEMY_CLEANUP_FRAME_OFFSET == 0 and not enemies_in_range.is_empty(): 
		var cleaned_keys = enemies_in_range.values().filter(is_instance_valid)
		enemies_in_range.clear()
		for e in cleaned_keys:
			enemies_in_range.set(e.get_instance_id(), e)
		


## Returns the target closest to our position based on the enemies_in_range Dictionary.
func get_closest_target() -> void:
	# Return the closest mob that overlaps the weapon range collider
	if not enemies_in_range.is_empty():
		if closest_enemy == null: closest_enemy = enemies_in_range.values().pick_random() # If we don't have a closest target make a random enemy the new closest target.
		for enemy_ID in enemies_in_range:
			if enemies_in_range[enemy_ID].global_position.distance_to(global_position) < closest_enemy.global_position.distance_to(global_position):
				closest_enemy = enemies_in_range[enemy_ID]

## Returns the target with the highest HP that is in weapon range.
func get_highest_hp_target() -> void:
	# Returns the highest HP enemy in range.
	if not enemies_in_range.is_empty():
		if highest_hp_enemy_in_range == null: highest_hp_enemy_in_range = enemies_in_range.values().pick_random() # If we don't have a highest hp enemy anymore set to a random enemy.
		for enemy_ID in enemies_in_range:
			if enemies_in_range[enemy_ID].stats.get_stat(Stat.HEALTH) > highest_hp_enemy_in_range.stats.get_stat(Stat.HEALTH):
				highest_hp_enemy_in_range = enemies_in_range[enemy_ID]

## When the enemy enters range, add them to the [enemies_in_range] dictionary. Then, if we target by HP, sort the dictionary by max HP.
func _on_area_entered(area:Area2D) -> void:
	if area is Enemy:
		# If this weapon targest the enemy with the highest HP, check if we have a highest HP enemy. If we don't, assign this area to it. Otherwise compare it to the highest and adjust the container if it is the new highest HP enemy.
		if target_type == TargetType.HIGHEST_HP:
			if highest_hp_enemy_in_range == null or enemies_in_range.is_empty(): # Or if the enemies dict is enmpty
				highest_hp_enemy_in_range = area
			else:
				# Get the HP of the current enemy. If this new enemy's HP is greater, they're the new highest HP enemy.
				if area.stats.get_stat(Stat.HEALTH) > highest_hp_enemy_in_range.stats.get_stat(Stat.HEALTH):
					highest_hp_enemy_in_range = area

		
		# Add the enemy to the dictionary.
		enemies_in_range.set(area.get_instance_id(), area)
		# Sorts the array by the highest HP at the front. Used when an enemy dies to automatically make the next highest HP enemy the new target
		
		

func _on_area_exited(area:Area2D) -> void:
	remove_enemy(area.get_instance_id())

## When the enemy exits range, remove them from the array. if they were the highest HP enemy, make the new front element of [enemies_in_range] the highest HP enemy if applicable.
# func old_remove_enemy_TODO(area:Area2D) -> void:
# 	if area is Enemy:
# 		var update_closest_target = false
# 		if enemies_in_range.keys().has(area): # Check if the enemy is in the dictionary.
# 			if target_type == TargetType.HIGHEST_HP and area == highest_hp_enemy_in_range and enemies_in_range.keys().size() > 1:  # If we target the highest HP and this the area exiting, make the enemy in [1] the next one.
# 				highest_hp_enemy_in_range = enemies_in_range.keys().get(1) # Sets the highest HP enemy to the second element. The dictionary is sorted based on this. This sounds maybe less and less a good idea. We shall see.
# 			elif  target_type == TargetType.CLOSEST and closest_enemy == area: update_closest_target = true # If the enemy being removed was the closest we need to update the Dictionary at the end of the loop.
# 			# Remove the enemy from the array.
# 			enemies_in_range.keys().erase(area)
# 			if update_closest_target: get_closest_target()

## Clear our enemy dictionary of all references.
func cleanup_enemies() -> void: enemies_in_range.clear()

## Removes the enemy from the array based on the instance_id (key)
func remove_enemy(instance_id: int) -> void:
	if enemies_in_range.has(instance_id):
		enemies_in_range.erase(instance_id)
		# After erasing the enemy, make sure it doesn't match our targeting type.
		match TargetType:
			TargetType.CLOSEST: # Null the closest_enemy var so we get a new one on the next targeting pass.
				if closest_enemy.get_instance_id() == instance_id: 
					closest_enemy = null
					# get_closest_target()
			TargetType.HIGHEST_HP: # Null the highest_hp enemy so we get a new one on the next targeting pass.
				if highest_hp_enemy_in_range.get_instance_id() == instance_id: 
					highest_hp_enemy_in_range = null
					# get_highest_hp_target()

func reset_timer() -> void:
	# print(cooldown_timer)
	cooldown_timer.stop()
	cooldown_timer.wait_time = cooldown
	ready_to_fire = false
	
func fire_weapon() -> void:
	# print_debug(get_parent().name + " is firing!")
	if cooldown_timer.is_stopped():
		ready_to_fire = false
		cooldown_timer.start()
		fire.emit()
	# print_debug("fire")

func set_stats(base_damage: float, base_speed: float, base_cooldown: float):
	level = 1
	damage = base_damage
	speed = base_speed
	cooldown = base_cooldown

func _on_weapon_timer_timeout() -> void:
	ready_to_fire = true

## Handles damage calcs for things like critical hits etc.
func damage_calc() -> float:
	if crit_chance == 0:
		return damage
	elif (randf() <= crit_chance):
		# print("Crit with " + get_parent().name)
		critical_hit.emit()
		return damage * crit_mod
	else: return damage

func get_weapon_range() -> float: return %WeaponRange.shape.radius ## Returns the weapon range (the radius of the collider)
func is_overhaul_enabled() -> bool: return level >= OVERHAUL_LEVEL ## Check to see if we've reached the level of our overhaul.
