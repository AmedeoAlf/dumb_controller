package dumb_controller

import "base:intrinsics"
import "controller_lib"
import "core:fmt"
import "core:hash"
import "core:mem"
import "core:net"
import "mouse_lib"

hash_packet :: proc(packet: ^Input_Packet) -> u32be {
	packet.hash = 0
	return u32be(hash.crc32(mem.any_to_bytes(packet^)))
}

hash_ok :: proc(packet: ^Input_Packet) -> bool {
	curr := packet.hash
	return hash_packet(packet) != curr
}

handle_input :: proc(packet: ^Input_Packet, endpoint: ^net.Endpoint) {
	// TODO: maybe ask for a resend
	if !hash_ok(packet) do return

	player := &players[obtain_player(&endpoint.address)]

	if packet.incremental != 0 && packet.incremental < player.incremental do return

	if packet.mouse.offset.x != 0 || packet.mouse.offset.y != 0 {
		mouse_lib.move_mouse(
			player.mouse_dev,
			i32(packet.mouse.offset.x),
			i32(packet.mouse.offset.y),
		)
	}

	{
		diff := packet.mouse.btns ~ player.mouse_btns
		for btn in diff {
			mouse_lib.emit_btn(player.mouse_dev, btn, btn in packet.mouse.btns)
		}
	}

	controller_lib.filter_btns(&packet.gamepad)
	controller_lib.handle_diff(player.device, &player.gamepad, &packet.gamepad)
	player.incremental = packet.incremental
}

main :: proc() {
	sock, sock_err := net.make_bound_udp_socket(
		net.IP4_Address{0, 0, 0, 0},
		8081,
	)
	if sock_err != nil do die(sock_err)

	dump_struct_size(Input_Packet)

	print_ips()

	buffer: [1024]byte
	for {
		fmt.print("\nReady ")
		read, endpoint, err := net.recv_udp(sock, buffer[:])
		if read < 1 do continue
		fmt.println("got packet", Packet_Type(buffer[0]), read)
		switch Packet_Type(buffer[0]) {
		case .INPUT:
			if read != 1 + size_of(Input_Packet) {
				fmt.eprintfln(
					"Got a %d byte packet (not %d)",
					read,
					size_of(Input_Packet) + 1,
				)
				fmt.eprintln(transmute(^Input_Packet)raw_data(buffer[1:]))
				continue
			}
			data := transmute(^Input_Packet)raw_data(buffer[1:])
			handle_input(data, &endpoint)
		case .PLAYER_NUM:
			player := obtain_player(&endpoint.address)
			answer := []byte {
				u8(Packet_Type.PLAYER_NUM),
				u8(player >> 8),
				u8(player),
			}
			net.send_udp(sock, answer, endpoint)
		case .BROADCAST:
			#assert(u8(Packet_Type.BROADCAST) == 2)
			MAGIC :: string("\002dumb_controller")
			if mem.compare(buffer[:read], transmute([]u8)MAGIC) != 0 do continue
			net.send_udp(sock, buffer[:read], endpoint)
		}
		for p in players[:player_count] do fmt.println(p)
	}
}
