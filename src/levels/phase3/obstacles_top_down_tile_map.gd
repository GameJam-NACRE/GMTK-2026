extends TileMapLayer

@export var obstacle_scene: PackedScene 

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if not obstacle_scene:
		push_warning("N'oublie pas d'assigner obstacle.tscn dans l'Inspecteur !")
		return

	_convert_tiles_to_obstacles()

func _convert_tiles_to_obstacles() -> void:
	var used_cells = get_used_cells()

	for cell in used_cells:
		var source_id = get_cell_source_id(cell)
		var atlas_coords = get_cell_atlas_coords(cell)
		var tile_set_source = tile_set.get_source(source_id) as TileSetAtlasSource

		if not tile_set_source:
			continue

		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = tile_set_source.texture
		atlas_texture.region = tile_set_source.get_tile_texture_region(atlas_coords)
		var local_pos = map_to_local(cell) * scale
		var global_tile_pos = local_pos + global_position

		var obstacle_instance = obstacle_scene.instantiate()
		obstacle_instance.global_position = global_tile_pos
		obstacle_instance.scale = scale

		if "texture" in obstacle_instance:
			obstacle_instance.texture = atlas_texture
		elif obstacle_instance.has_node("Sprite2D"):
			obstacle_instance.get_node("Sprite2D").texture = atlas_texture

		get_parent().add_child.call_deferred(obstacle_instance)

	clear()
