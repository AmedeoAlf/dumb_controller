package dumb_controller

import "controller_lib"
import "core:net"
import "core:sys/linux"
import "mouse_lib"

players: [16]Player

player_count := 0

NAME :: "dumb controller X"
get_name :: proc() -> (name: [len(NAME) + 1]byte) {
	copy(name[:], NAME)
	name[len(NAME) - 1] = byte(player_count) + 'a'
	name[len(NAME)] = 0
	return
}

create_player :: proc(addr: ^net.Address) {
	// FIXME: actually handle max players
	if player_count == len(players) do player_count -= 1

	name := get_name()
	device := controller_lib.make(string(name[:])) or_else -1
	players[player_count] = Player {
		incremental = 0,
		addr        = addr^,
		device      = device,
	}

	if player_count < 1 {
		mouse, err := mouse_lib.make_mouse()
		assert(
			err == .NONE,
			"Could not create a mouse for controller, maybe I should not crash ;-)",
		)
		players[player_count].mouse = mouse
	} else {
		players[player_count].mouse = players[player_count - 1].mouse
	}

	player_count += 1
}

// returns -1 on not found
get_player :: proc(addr: ^net.Address) -> int {
	for p, i in players[:player_count] {
		if p.addr == addr^ do return i
	}
	return -1
}

// Must return a player id (creates one if necessary)
obtain_player :: proc(addr: ^net.Address) -> int {
	player_id := get_player(addr)
	if player_id != -1 do return player_id

	create_player(addr)
	return player_count - 1
}
