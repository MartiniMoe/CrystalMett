extends Node

# Controllers are named "<name>:<ip>"; their LEDs are set via UDP.

func get_ip(js):
	# touch pads (see controls.gd) have no LEDs
	if js >= controls.FIRST_PAD:
		return null

	var splitted_name = Input.get_joy_name(js).split(":")

	if splitted_name.size() == 2:
		return splitted_name[1]
	else:
		return null

func set_led(js, led, red, green, blue, brightness):
	var ip = get_ip(js)
	if ip == null:
		return

	var data = PackedByteArray([0x20 + led, int(red), int(green), int(blue), int(brightness), 0x20 + led])

	var udp = PacketPeerUDP.new()
	var status = udp.set_dest_address(ip, 1337)

	if status == OK:
		udp.put_packet(data)

	udp.close()

func get_player_name(js):
	if js >= controls.FIRST_PAD:
		return "Touch " + str(js - controls.FIRST_PAD + 1)

	var splitted_name = Input.get_joy_name(js).split(":")

	if splitted_name.size() == 2:
		return splitted_name[0]
	elif Input.get_joy_name(js) != "":
		return Input.get_joy_name(js)
	else:
		return "Joypad " + str(js)
