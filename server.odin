package dumb_controller

import "base:intrinsics"
import "core:fmt"
import "core:hash"
import "core:mem"
import "core:net"
import "uinput"

hash_packet :: proc(packet: ^Input_Packet) -> u32be {
	packet.hash = 0
	return u32be(hash.crc32(mem.any_to_bytes(packet^)))
}

hash_ok :: proc(packet: ^Input_Packet) -> bool {
	curr := packet.hash
	return hash_packet(packet) != curr
}

_uinput_key_from_btn :: proc(btn: Button) -> uinput.KEY {
	switch btn {
	case .SOUTH:
		return .BTN_SOUTH
	case .WEST:
		return .BTN_WEST
	case .NORTH:
		return .BTN_NORTH
	case .EAST:
		return .BTN_EAST
	case .START:
		return .BTN_START
	case .SELECT:
		return .BTN_SELECT
	case .LB:
		return .BTN_TL
	case .RB:
		return .BTN_TR
	case .LT:
		return .BTN_TL2
	case .RT:
		return .BTN_TR2
	case .LS:
		return .BTN_THUMBL
	case .RS:
		return .BTN_THUMBR
	case:
		return nil
	}
}

filter_btns :: proc(state: ^Gamepad_State) {
	nums := transmute(Buttons_Underlying)state.buttons
	nums &= Buttons_Underlying((1 << len(Button)) - 1)
	state.buttons = transmute(bit_set[Button;Buttons_Underlying])nums
}

handle_diff :: proc(player: ^Player, state: ^Gamepad_State) {
	// Some weird ass bug makes it need to be treaded as little endian to work
	changed := transmute(bit_set[Button;u16le])(player.state.buttons ~ state.buttons)
	for btn in changed {
		key := _uinput_key_from_btn(btn)
		if key != nil do uinput.emit(player.device, key, btn in state.buttons)
	}
}

handle_input :: proc(packet: ^Input_Packet, endpoint: ^net.Endpoint) {
	// TODO: maybe ask for a resend
	if !hash_ok(packet) do return

	player := &players[obtain_player(&endpoint.address)]

	if packet.incremental != 0 && packet.incremental < player.incremental do return

	filter_btns(&packet.state)
	handle_diff(player, &packet.state)
	player.state = packet.state
	player.incremental = packet.incremental
}

main :: proc() {
	sock, sock_err := net.make_bound_udp_socket(net.IP4_Address{0, 0, 0, 0}, 8081)
	if sock_err != nil do die(sock_err)

	buffer: [1024]byte
	for {
		fmt.print("\nReady ")
		read, endpoint, err := net.recv_udp(sock, buffer[:])
		if read < 1 do continue
		fmt.println("got packet", Packet_Type(buffer[0]), read)
		switch Packet_Type(buffer[0]) {
		case .INPUT:
			if read != 1 + size_of(Input_Packet) do continue
			data := transmute(^Input_Packet)raw_data(buffer[1:])
			handle_input(data, &endpoint)
		case .PLAYER_NUM:
			player := obtain_player(&endpoint.address)
			answer := []byte{u8(Packet_Type.PLAYER_NUM), u8(player >> 8), u8(player)}
			net.send_udp(sock, answer, endpoint)
		}
		for p in players[:player_count] do fmt.println(p)
	}
}
