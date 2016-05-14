extends RigidBody2D

var move_accel = 800
var move_deaccel = 800
var move_max = 200

export var joystick_number = 0
export var team = 0
export var player_number = 0
var joy_tresh = 0.5

var pig_carry_counter = 0
var pig_max_carry = 5
var pig_more_time_counter = 0
var pig_max_more_time = 20

var mov_x = 0
var mov_y = 0

var item = 0
var old_item = -1
const ITEM_NONE = 0
const ITEM_CRYSTAL = 1
const ITEM_BERNCRYSTAL = 2
const ITEM_DYNAMITE = 3
const ITEM_GEAR = 4

const factory_normal = preload("res://gfx/factory.png")
const factory_closed = preload("res://gfx/FactorySign.png")

const player_sprite_normal = preload("res://gfx/player.png")
const player_sprite_crystal = preload("res://gfx/PlayerCrystal.png")
const player_sprite_berncrystal = preload("res://gfx/PlayerBernschwein.png")
const player_sprite_dynamite = preload("res://gfx/PlayerDynamite.png")
const player_sprite_gear = preload("res://gfx/PlayerGear.png")

const player_shirt_normal = preload("res://gfx/player_Shirt.png")
const player_shirt_crystal = preload("res://gfx/PlayerCrystal_Shirt.png")
const player_shirt_berncrystal = preload("res://gfx/PlayerBernschweinShirt.png")
const player_shirt_dynamite = preload("res://gfx/PlayerDynamiteShirt.png")
const player_shirt_gear = preload("res://gfx/PlayerGearShirt.png")

const item_berncrystal = preload("res://gfx/BonusBernschwein.png")
const item_colorchange = preload("res://gfx/BonusColorchange.png")
const item_dynamite = preload("res://gfx/BonusDynamite.png")
const item_gear = preload("res://gfx/gear.png")
const item_einstein = preload("res://gfx/BonusEinstein.png")

var anim_player = null
var anim_item = null
var sprite_player = null
var sprite_shirt = null
var sprite_item = null
var particle_fire = null
var particle_explosion = null

var push_timer = 0

var team1 = Color(1, 0, 0, 1)
var team2 = Color(0, 1, 0, 1)
var team3 = Color(0, 0, 1, 1)
var team4 = Color(1, 1, 0, 1)

func _ready():
	add_to_group("zsort")
	add_to_group("player")
	
	anim_player = get_node("anim_player")
	anim_item = get_node("anim_item")
	sprite_player = get_node("sprite_player")
	sprite_shirt = get_node("sprite_player/shirt")
	sprite_item = get_node("sprite_item")
	particle_fire = get_node("fire")
	particle_explosion = get_node("explosion")
	
	
	set_fixed_process(true)
	set_sprites()
	
	anim_player.play("walk")
	
func init_player():
	if team == 0:
		sprite_shirt.set_modulate(team1)
	if team == 1:
		sprite_shirt.set_modulate(team2)
	if team == 2:
		sprite_shirt.set_modulate(team3)
	if team == 3:
		sprite_shirt.set_modulate(team4)

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		#turn off LEDs on quit:
		leds.set_led(player_number, 0, 0, 0, 0, 0)
		leds.set_led(player_number, 1, 0, 0, 0, 0)
		
		get_tree().quit() # default behavior

func set_sprites():
	if old_item != item:
		if item == ITEM_NONE:
			sprite_player.set_texture(player_sprite_normal)
			sprite_shirt.set_texture(player_shirt_normal)
			sprite_item.set_texture(null)
			particle_fire.set_emitting(false)
			pig_carry_counter = 0
		elif item == ITEM_CRYSTAL:
			sprite_player.set_texture(player_sprite_crystal)
			sprite_shirt.set_texture(player_shirt_crystal)
			sprite_item.set_texture(null)
		elif item == ITEM_BERNCRYSTAL:
			sprite_player.set_texture(player_sprite_berncrystal)
			sprite_shirt.set_texture(player_shirt_berncrystal)
			sprite_item.set_texture(item_berncrystal)
			particle_fire.set_amount(16)
		elif item == ITEM_DYNAMITE:
			sprite_player.set_texture(player_sprite_dynamite)
			sprite_shirt.set_texture(player_shirt_dynamite)
			sprite_item.set_texture(item_dynamite)
		elif item == ITEM_GEAR:
			sprite_player.set_texture(player_sprite_gear)
			sprite_shirt.set_texture(player_shirt_gear)
			sprite_item.set_texture(item_gear)
		old_item = item
		anim_item.play("item")

func set_frames(var frame):
	sprite_player.set_frame(frame)
	sprite_shirt.set_frame(frame)

func _fixed_process(delta):
	push_timer -= delta
	var mv = get_linear_velocity()
	var walking = false
	set_sprites()
	
	if item == ITEM_CRYSTAL || item == ITEM_BERNCRYSTAL:
		pig_carry_counter += delta
		pig_more_time_counter += delta
		leds.set_led(player_number, 1, 255, 0, 255, 1)
			
		if pig_carry_counter > pig_max_carry:
			# PIG EXPLODE
			pig_carry_counter = 0
			item = ITEM_NONE
			particle_fire.set_emitting(false)
			particle_explosion.set_emitting(true)
			#dim right LED
			leds.set_led(player_number, 1, 255, 0, 255, 0)
		elif pig_carry_counter > (pig_max_carry-(pig_max_carry/4)):
			particle_fire.set_amount(128)
			leds.set_led(player_number, 1, 255, 0, 255, 7)
		elif pig_carry_counter > pig_max_carry/2:
			particle_fire.set_amount(64)
			leds.set_led(player_number, 1, 255, 0, 255, 5)
		elif pig_carry_counter > pig_max_carry/3:
			particle_fire.set_amount(16)
			leds.set_led(player_number, 1, 255, 0, 255, 4)
			particle_fire.set_emitting(true)
		
		if pig_more_time_counter > pig_max_more_time:
			pig_max_carry = 5
			
	if Input.get_joy_axis(player_number, 1) > joy_tresh:
		walking = true
		if mv.y < move_max:
			mv.y += move_accel*delta
			mov_y = 1
	elif Input.get_joy_axis(player_number,  1) < -joy_tresh:
		walking = true
		if mv.y > -move_max:
			mv.y -= move_accel*delta
			mov_y = -1
	else:
		mov_y = 0
		var yv = abs(mv.y)
		yv -= move_deaccel*delta
		if yv < 0:
			yv = 0
		mv.y = sign(mv.y)*yv
	
	if Input.get_joy_axis(player_number, 0) > joy_tresh:
		walking = true
		if mv.x < move_max:
			mv.x += move_accel*delta
			mov_x = 1
	elif Input.get_joy_axis(player_number,  0) < -joy_tresh:
		walking = true
		if mv.x > -move_max:
			mv.x -= move_accel*delta
			mov_x = -1
	else:
		mov_x = 0
		var xv = abs(mv.x)
		xv -= move_deaccel*delta
		if xv < 0:
			xv = 0
		mv.x = sign(mv.x)*xv
	
	if walking:
		if !anim_player.is_playing():
			anim_player.play("walk")
	else:
		anim_player.stop()
	
	if mov_x == 0 && mov_y == 1:
		# unten
		set_frames(1)
	elif mov_x == 0 && mov_y == -1:
		# oben
		set_frames(4)
	elif mov_y == 0 && mov_x == -1:
		# links
		set_frames(6)
	elif mov_y == 0 && mov_x == 1:
		# rechts
		set_frames(2)
	elif mov_x == -1 && mov_y == 1:
		# unten links
		set_frames(7)
	elif mov_x == 1 && mov_y == 1:
		# unten rechts
		set_frames(0)
	elif mov_x == -1 && mov_y == -1:
		# oben links
		set_frames(5)
	elif mov_x == 1 && mov_y == -1:
		# oben rechts
		set_frames(3)
	
	set_linear_velocity(mv)
	
func _integrate_forces(state):
	if state.get_contact_count() > 0:
		for x in range(state.get_contact_count()):
			var o = state.get_contact_collider_object(x)
			if "pig" in o.get_groups() && item == ITEM_NONE:
				o.set_collision_mask(8)
				o.set_layer_mask(8)
				o.queue_free()
				item = ITEM_CRYSTAL
			elif "player" in o.get_groups():
				if get_linear_velocity().length() > o.get_linear_velocity().length() && push_timer <= 0:
					push_timer = 1
					o.push_timer = 1
					if o.item != ITEM_NONE && item == ITEM_NONE:
						if o.item == ITEM_CRYSTAL || o.item == ITEM_BERNCRYSTAL:
							pig_carry_counter = o.pig_carry_counter
							particle_fire.set_amount(o.particle_fire.get_amount())
							particle_fire.set_emitting(o.particle_fire.is_emitting())
						item = o.item
						o.item = ITEM_NONE
					o.apply_impulse(get_pos(), get_linear_velocity().normalized()*600)
			elif "factory" in o.get_groups() && !o.gear_missing && item == ITEM_CRYSTAL:
				# Crystal
				item = ITEM_NONE
				pig_carry_counter = 0
				o.process_pig("normal")
			elif "factory" in o.get_groups() && !o.gear_missing && item == ITEM_BERNCRYSTAL:
				# Bernschwein
				item = ITEM_NONE
				pig_carry_counter = 0
				o.process_pig("bernschwein")
			elif "factory" in o.get_groups() && !o.gear_missing && item == ITEM_DYNAMITE:
				# Dynamite
				o.get_node("Sprite").set_texture(factory_closed)
				o.get_node("Sprite").set_hframes(1)
				o.get_node("Sprite").set_frame(0)
				item = ITEM_NONE
				o.process_pig("dynamite")
			elif "factory" in o.get_groups() && o.gear_missing && item == ITEM_GEAR:
				# Gear
				o.get_node("Sprite").set_texture(factory_normal)
				o.get_node("Sprite").set_hframes(6)
				item = ITEM_NONE
				o.gear_missing = false
			elif "gear" in o.get_groups() && item == ITEM_NONE:
				o.set_collision_mask(8)
				o.set_layer_mask(8)
				o.queue_free()
				item = ITEM_GEAR
			elif "supply" in o.get_groups() && item == ITEM_NONE:
				o.set_collision_mask(8)
				o.set_layer_mask(8)
				o.queue_free()
				if o.item == "bernschwein":
					item = ITEM_BERNCRYSTAL
				elif o.item == "colorchange":
					sprite_item.set_texture(item_colorchange)
					anim_item.play("item")
					get_node("/root/MainNode").rotate_factory_teams()
				elif o.item == "dynamite":
					item = ITEM_DYNAMITE
				elif o.item == "einstein":
					sprite_item.set_texture(item_einstein)
					anim_item.play("item")
					pig_max_carry = 10