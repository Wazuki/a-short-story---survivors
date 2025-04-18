## Every weapon that overrides [func initialize(data)], [func _process] or [func _on_area_entered] MUST call the super for those first.
class_name  Weapon
extends Area2D

# Quick access enums:
const SceneKey = WeaponEnums.SceneKey # Assigns the WeaponEnums enum for quick access.
const Type = WeaponEnums.Type # Assigns the WeaponData enum for quick access.
const TargetType = WeaponEnums.TargetType # Assigns the WeaponData enum for quick access.
#const Stat = CharacterData.Stat # Assigns the CharacterData enum for quick access.

# Other offset constants
const FRAME_UPDATE_OFFSET = 6 ## The number of frames between each targeting update.
#const ENEMY_CLEANUP_FRAME_OFFSET = 15 ## The number of frames between each enemy cleanup.

# Descriptive elements
var description: String
var icon: AtlasTexture
var level_up_texts: Array[String] = [] ## The text for each level up (Max 7)

# Enumerated Statistics
var weapon_type: Type ## The type of weapon based on the Weapon Type enum.
var target_type = TargetType.NONE ## Determines the targeting logic for the weapon.

# Calculated Weapon statistics
var level: int = 1 ## The level of the weapon. Used for leveling up and determining the weapon's stats.
var damage: float ## The damage of the weapon.
var speed: float ## The speed of the weapon (attack speed, lightning jump speed, etc.)
var projectile_count: int ## The number of "projectiles" the weapon fires per attack.
var cooldown: float ## The cooldown of the weapon (how often it can attack)
var crit_chance: float ## The base critical chance of the weapon.
var crit_mod: float ## The base critical damage modifier of the weapon.
var weapon_scale: Vector2 = Vector2.ONE ## The scale of the weapon. Used for scaling the weapon's size.
var level_up_augments ## The augments that will be applied to the weapon on each level. Indexed at level -2 

# UI Elements
var cooldown_timer: Timer
var ready_to_fire: bool
var cooldown_panel

# Targeting Data - Variables to keep track of what our closest targets are for that type of weapon.
@export var collision_shape: CollisionShape2D ## The collision shape of the weapon, used to determine the weapon's range.
var weapon_range: float ## The range of the weapon, used to change the size of the collider.
var highest_hp_enemy_in_range: Enemy = null
var closest_enemy: Enemy = null
var enemies_in_range = {} ## An [int]-[Enemy] dictionary that tracks enemies in our colliders. Use [method get_instance_id()] to get the instance ID.

# Packed scenes
var projectile_scenes: Dictionary = {} ## Dictionary of packed scenes for the weapon. Should be scene name, packed scene.

## Deprecated. Will be tied into the new weapon data system.
# var first_level_up: bool = true:
# 	get:
# 		return first_level_up
# 	set(value):
# 		first_level_up = value
# 		if not first_level_up: create_cooldown_panel.emit() # Emit the signal only if we are now false - theoretically should only be called once?



signal fire
signal critical_hit
#signal create_cooldown_panel
signal begin_attack_sequence
signal gained_level(value)

const OVERHAUL_LEVEL = 7

## Initialize the weapon with the data from the WeaponData resource.[br]
## Must be called [b]BEFORE[/b] the weapon is added to the scene tree.
func initialize(data: WeaponData) -> void:
	# Initialize the weapon with the data from the WeaponData resource.
	name = data.name
	weapon_type = data.weapon_type as Type
	description = data.description
	icon = data.icon
	level_up_texts = data.level_up_texts
	level_up_augments = data.level_up_augments.duplicate(true) # Duplicate to prevent modifying the original data along with a deep copy to preserve each object in the array.

	damage = data.damage
	speed = data.speed
	projectile_count = data.projectile_count
	cooldown = data.cooldown
	crit_chance = data.crit_chance
	crit_mod = data.crit_mod

	weapon_range = data.weapon_range
	target_type = data.target_type as TargetType
	if data.projectile_scene_map != null: projectile_scenes = data.projectile_scene_map.to_dict()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the weapon timer programmatically.
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	cooldown_timer.autostart = true # Star the timer automatically (for use with instantiation)
	cooldown_timer.connect("timeout", _on_weapon_timer_timeout)
	
	# Connect the signal remove_enemy(enemy) to our remove_enemy function
	EnemyManager.remove_invalid_enemy.connect(remove_enemy)
	EnemyManager.cleanup.connect(cleanup_enemies)
	
	add_child(cooldown_timer)
	# cooldown_timer.wait_time = cooldown
	update_weapon_range() # Update the weapon range collider to match the weapon range.
	ready_to_fire = false

## Return a new bullet instanced based on the passed scene key. The bullet will return pre-initialized.
func instantiate_projectile_by_key(key: SceneKey, spawn_pos: Vector2, index: SpriteConstants.Z_INDEX, target_node: Node2D = null) -> Projectile:
	# Returns a new bullet instance based on the key.
	if projectile_scenes.has(key):
		var new_projectile = projectile_scenes[key].projectile_scene.instantiate() as Projectile
		new_projectile.initialize(self, projectile_scenes[key], spawn_pos, index, target_node)
		return new_projectile
	else:
		print_debug("Projectile scene not found for: ", str(key))
	return null

# ## Return the level up texts from the weapon data. This is used for the level up GUI.
# func get_level_up_texts(new_level: int) -> String:
# 	if level_up_texts.size() > 0: return level_up_texts[new_level]
# 	else:
# 		print_debug("No level up texts found for weapon: ", name)
# 		return ""

## Level up the weapon - increase the new level, emit the signal indicating our new level, and update the weapon with all augments from the data.
func level_up() -> void:
	level += 1
	gained_level.emit(level)
	# Check to see if our new level has any augments to apply to the weapon.
	if level > 1: # Level 1 is the base level and doesn't have any augments.
		#if level_up_augments == null: print_debug("No augments found for " + name + " at level " + str(level))
		if level_up_augments[level - 2].size() > 0: # Index at - 2 to account for augments only beginning after the first level.
			for augment in level_up_augments[level - 2]:
				# print_debug("Applying augment: ", augment)
				if augment is Augment: # Sanity check to make sure we didn't get a null or invalid augment.
					augment.apply_augment(self) # Apply the augment to the weapon, passing in ourself as the target.
				else: push_error("Invalid augment found for weapon: ", name, " at level: ", level, " augment: ", augment)


	
# ## Return the level up augments from the weapon data. This is used for level up affects applied to a weapon.[br]
# ## Pass in the weapons' new level. A level one or zero will return an empty array.[br]
# ## Internally, the augments for level [i]n[/i] is at index([i]n[/i]-2).
# func get_level_up_augments(current_level: int) -> Array[WeaponAugment]:
# 	if level_up_augments.size() == 0: return []
# 	if current_level >= 2:
# 		return level_up_augments[current_level-2]
	
# 	push_warning("Level up augments not found for weapon: ", name)
# 	return []

## Updates the target based on the targetting type. Requires any overriding derived classes to call super._process!()
func _process(_delta: float) -> void:
	if GameController.global_frame_count % FRAME_UPDATE_OFFSET == 0:
		if target_type == TargetType.CLOSEST: get_closest_target()
		elif target_type == TargetType.HIGHEST_HP: get_highest_hp_target()

	# Cleans up the enemies_in_range array every so often to clear out dead enemies. TODO - consider signals.
	if GameController.global_frame_count % WeaponManager.ENEMY_CLEANUP_FRAME_OFFSET == 0 and not enemies_in_range.is_empty(): 
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
			if enemies_in_range[enemy_ID].stats[CharacterData.Stat.HEALTH] > highest_hp_enemy_in_range.stats[CharacterData.Stat.HEALTH]:
				highest_hp_enemy_in_range = enemies_in_range[enemy_ID]

## Returns a random valid enemy from the enemies in range collection.
func get_random_target_in_range() -> Enemy:
	if enemies_in_range.is_empty(): return null

	# Duplicate the key array and then pick a random one - if we get a valid target, return it. Otherwise, erase the invalid enemy and try again.
	while not enemies_in_range.is_empty():
		var keys = enemies_in_range.keys().duplicate()
		var index = keys.pick_random()
		if is_instance_valid(enemies_in_range[index]): return enemies_in_range[index]
		else:
			enemies_in_range.erase(index)

	return null

## Returns the enemy with the largest cluster of targets nearby.
func get_enemy_with_largest_cluster_in_range() -> Enemy:
	if enemies_in_range.is_empty(): return null

	return EnemyManager.find_cluster_center(enemies_in_range)


## When the enemy enters range, add them to the [enemies_in_range] dictionary. Then, if we target by HP, sort the dictionary by max HP.
func _on_area_entered(area:Area2D) -> void:
	if area is Enemy:
		# If this weapon targest the enemy with the highest HP, check if we have a highest HP enemy. If we don't, assign this area to it. Otherwise compare it to the highest and adjust the container if it is the new highest HP enemy.
		if target_type == TargetType.HIGHEST_HP:
			if highest_hp_enemy_in_range == null or enemies_in_range.is_empty(): # Or if the enemies dict is enmpty
				highest_hp_enemy_in_range = area
			else:
				# Get the HP of the current enemy. If this new enemy's HP is greater, they're the new highest HP enemy.
				if area.stats[CharacterData.Stat.HEALTH] > highest_hp_enemy_in_range.stats[CharacterData.Stat.HEALTH]:
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
	
## Automatically resets the cooldown timer (if stopped), sets [ready_to_fire] to false and emits the fire signal to notify listeners.
func fire_weapon() -> void:
	# print_debug(get_parent().name + " is firing!")
	if cooldown_timer.is_stopped():
		ready_to_fire = false
		cooldown_timer.wait_time = cooldown # Reset the cooldown timer to the actual cooldown in case we leveled up.
		cooldown_timer.start()
		fire.emit()
	# print_debug("fire")

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

## Update the [%WeaponRange]'s [shape] to match the weapon range.
func update_weapon_range() -> void:
	%WeaponRange.shape.radius = weapon_range

func get_weapon_range() -> float: return %WeaponRange.shape.radius ## Returns the weapon range (the radius of the collider)
func is_overhaul_enabled() -> bool: return level >= OVERHAUL_LEVEL ## Check to see if we've reached the level of our overhaul.

## Deprecated. Will be tied into the new weapon data system.
# func set_stats(base_damage: float, base_speed: float, base_cooldown: float) -> void:
# 	level = 1
# 	damage = base_damage
# 	speed = base_speed
# 	cooldown = base_cooldown
