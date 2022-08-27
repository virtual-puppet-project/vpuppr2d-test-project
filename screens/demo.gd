extends Node2D

class Drawable extends Node2D:
	enum Ops {
		NONE = 0,

		ADD,
		SUB
	}

	var top_l: Sprite
	var top_r: Sprite
	var bot_l: Sprite
	var bot_r: Sprite

	var sprites := {}

	var center := Vector2.ZERO
	var rect := Rect2()

	func _init(initial_rect: Rect2, p_center: Vector2, p_sprites: Dictionary) -> void:
		top_l = p_sprites.top_l
		top_r = p_sprites.top_r
		bot_l = p_sprites.bot_l
		bot_r = p_sprites.bot_r

		center = p_center
		rect = initial_rect

		sprites = p_sprites

	func _ready() -> void:
		position = rect.position

		for key in sprites.keys():
			add_child(sprites[key])

	func apply(offset: Vector2) -> void:
		for key in sprites.keys():
			var sprite: Sprite = sprites[key]

			var sprite_center := sprite.position
			var bounding_box := sprite.get_rect()

			var zero_offset := Vector2(
				(-bounding_box.position.x) / bounding_box.size.x,
				(-bounding_box.position.y) / bounding_box.size.y
			)

			# var x_op: int = Ops.ADD if key in ["top_r", "bot_r"] else Ops.SUB
			# var y_op: int = Ops.ADD if key in ["bot_l", "bot_r"] else Ops.SUB

			var new_scale := Vector2(
				(sprite_center.x - offset.x) / bounding_box.size.x,
				(sprite_center.y - offset.y) / bounding_box.size.y
			)

			var new_pos: Vector2 = offset + (rect.size * zero_offset)

			var postxf := Transform2D()
			postxf = postxf.rotated(rotation)
			
			new_pos = postxf.xform(new_pos)

			sprite.position += new_pos
			sprite.scale *= new_scale

onready var camera: Camera2D = $Camera2D

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _init() -> void:
	OS.center_window()

func _ready() -> void:
	var model_root := Node2D.new()
	model_root.name = "Model"
	add_child(model_root)
	
	#region Head
	
	var ref_head: Sprite = $ModelRoot/Head
	
	var head_textures := _split_texture(ref_head)
	var head_sprites := _construct_sprites(ref_head.position, head_textures)

	var head_drawable := Drawable.new(
		Rect2(ref_head.position, ref_head.get_rect().size), ref_head.position, head_sprites)
	head_drawable.name = "Head"
	model_root.add_child(head_drawable)
	
	#endregion
	
	#region Nose
	
	var ref_nose: Sprite = $ModelRoot/Head/Nose

	var nose_textures := _split_texture(ref_nose)
	var nose_sprites := _construct_sprites(ref_nose.position, nose_textures)

	var nose_drawable := Drawable.new(
		Rect2(ref_nose.position, ref_nose.get_rect().size), ref_nose.position, nose_sprites)
	nose_drawable.name = "Nose"
	model_root.add_child(nose_drawable)

	#endergion

	#region Mouth
	
	var ref_mouth: Sprite = $ModelRoot/Head/Mouth
	
	var mouth_textures := _split_texture(ref_mouth)
	var mouth_sprites := _construct_sprites(ref_mouth.position, mouth_textures)

	var mouth_drawable := Drawable.new(
		Rect2(ref_mouth.position, ref_mouth.get_rect().size), ref_mouth.position, mouth_sprites)
	mouth_drawable.name = "Mouth"
	model_root.add_child(mouth_drawable)

	#endregion
	
	var ref_left_eye_socket: Sprite = $ModelRoot/Head/LeftEyeSocket
	var left_eye_socket_textures := _split_texture(ref_left_eye_socket)
	var left_eye_socket_sprites := _construct_sprites(ref_left_eye_socket.position, left_eye_socket_textures)

	var left_eye_socket_drawable := Drawable.new(
		Rect2(ref_left_eye_socket.position, ref_left_eye_socket.get_rect().size),
		ref_left_eye_socket.position,
		left_eye_socket_sprites
	)
	left_eye_socket_drawable.name = "LeftEyeSocket"
	model_root.add_child(left_eye_socket_drawable)
	
	var ref_left_eye: Sprite = $ModelRoot/Head/LeftEyeSocket/LeftEye
	var left_eye_textures := _split_texture(ref_left_eye)
	var left_eye_sprites := _construct_sprites(ref_left_eye_socket.position + ref_left_eye.position, left_eye_textures)

	var left_eye_drawable := Drawable.new(
		Rect2(ref_left_eye_socket.position + ref_left_eye.position, ref_left_eye.get_rect().size),
		ref_left_eye_socket.position + ref_left_eye.position,
		left_eye_sprites
	)
	left_eye_drawable.name = "LeftEye"
	left_eye_socket_drawable.add_child(left_eye_drawable)
	
	var ref_right_eye_socket: Sprite = $ModelRoot/Head/RightEyeSocket
	var right_eye_socket_textures := _split_texture(ref_right_eye_socket)
	var right_eye_socket_sprites := _construct_sprites(ref_right_eye_socket.position, right_eye_socket_textures)

	var right_eye_socket_drawable := Drawable.new(
		Rect2(ref_right_eye_socket.position, ref_right_eye_socket.get_rect().size),
		ref_right_eye_socket.position,
		right_eye_socket_sprites
	)
	right_eye_socket_drawable.name = "RightEyeSocket"
	model_root.add_child(right_eye_socket_drawable)
	
	var ref_right_eye: Sprite = $ModelRoot/Head/RightEyeSocket/RightEye
	var right_eye_textures := _split_texture(ref_right_eye)
	var right_eye_sprites := _construct_sprites(ref_right_eye_socket.position + ref_right_eye.position, right_eye_textures)

	var right_eye_drawable := Drawable.new(
		Rect2(ref_right_eye_socket.position + ref_right_eye.position, ref_right_eye.get_rect().size),
		ref_right_eye_socket.position + ref_right_eye.position,
		right_eye_sprites
	)
	right_eye_drawable.name = "RightEye"
	right_eye_socket_drawable.add_child(right_eye_drawable)
	
	$ModelRoot.queue_free()

#-----------------------------------------------------------------------------#
# Connections                                                                 #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

func _build_model(starting_node: Node) -> Node2D:
	var node2d := Node2D.new()

	return node2d



func _split_texture(sprite: Sprite) -> Dictionary:
	var texture: AtlasTexture = sprite.texture
	var region: Rect2 = texture.region
	region.size /= 2
	
	var top_l: AtlasTexture = texture.duplicate(true)
	top_l.region.size = region.size
	
	var top_r: AtlasTexture = texture.duplicate(true)
	top_r.region.size = region.size
	top_r.region.position.x += region.size.x
	
	var bot_l := texture.duplicate(true)
	bot_l.region.size = region.size
	bot_l.region.position.y += region.size.y
	
	var bot_r := texture.duplicate(true)
	bot_r.region.size = region.size
	bot_r.region.position += region.size
	
	return {
		"top_l": top_l,
		"top_r": top_r,
		"bot_l": bot_l,
		"bot_r": bot_r
	}

func _construct_sprites(ref_position: Vector2, textures: Dictionary) -> Dictionary:
	var top_l := Sprite.new()
	top_l.position.x = ref_position.x - (textures.top_l.region.size.x / 2)
	top_l.position.y = ref_position.y - (textures.top_l.region.size.y / 2)
	top_l.texture = textures.top_l
	
	var top_r := Sprite.new()
	top_r.position.x = ref_position.x + (textures.top_r.region.size.x / 2)
	top_r.position.y = ref_position.y - (textures.top_r.region.size.y / 2)
	top_r.texture = textures.top_r
	
	var bot_l := Sprite.new()
	bot_l.position.x = ref_position.x - (textures.bot_l.region.size.x / 2)
	bot_l.position.y = ref_position.y + (textures.bot_l.region.size.y / 2)
	bot_l.texture = textures.bot_l
	
	var bot_r := Sprite.new()
	bot_r.position.x = ref_position.x + (textures.bot_r.region.size.x / 2)
	bot_r.position.y = ref_position.y + (textures.bot_r.region.size.y / 2)
	bot_r.texture = textures.bot_r
	
	return {
		"top_l": top_l,
		"top_r": top_r,
		"bot_l": bot_l,
		"bot_r": bot_r
	}

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#
