package dumb_controller

import "base:intrinsics"
import "controller_lib"
import "core:fmt"
import "core:hash"
import "core:mem"
import "core:net"

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

	controller_lib.filter_btns(&packet.state)
	controller_lib.handle_diff(player.device, &player.state, &packet.state)
	player.incremental = packet.incremental
}

main :: proc() {
	sock, sock_err := net.make_bound_udp_socket(
		net.IP4_Address{0, 0, 0, 0},
		8081,
	)
	if sock_err != nil do die(sock_err)

	buffer: [1024]byte
	for {
		fmt.print("\nReady ")
		read, endpoint, err := net.recv_udp(sock, buffer[:])
		if read < 1 do continue
		fmt.println("got packet", Packet_Type(buffer[0]), read)
		switch Packet_Type(buffer[0]) {
		case .INPUT:
			if read != 1 + size_of(Input_Packet) {
				fmt.eprintln(
					"Got a",
					read,
					"byte sized packet (not",
					size_of(Input_Packet) + 1,
					")",
				)
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
		}
		for p in players[:player_count] do fmt.println(p)
	}
}
