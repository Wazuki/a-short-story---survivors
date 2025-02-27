extends Node2D

@export var noise_height_texture: NoiseTexture2D
var noise: Noise

var width = 100
var height = 100

var source_id = 0
var ground_atlas = Vector2i(6, 1)
var empty_atlas = Vector2i(6, 4)

func _ready() -> void:
	noise = noise_height_texture.noise
	generate_world()

func generate_world() -> void:
	for x in range(width):
		for y in range(height):
			var noise_value = noise.get_noise_2d(x, y)
			#print(noise_value)
			if noise_value >= 0.0:
				# Place a land tile
				%TileMapLayer.set_cell(Vector2i(x, y), source_id, ground_atlas)
			elif noise_value < 0.0:
				# Place an empty (blocked) tile
				%TileMapLayer.set_cell(Vector2i(x, y),source_id, empty_atlas)
