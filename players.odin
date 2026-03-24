package dumb_controller

import "core:net"
import "uinput"

players: [16]Player

player_count := 0

CONTROLLER_NAME :: "dumb_controller "
STICK_ABSINFO :: uinput.Absinfo {
	value   = 0, // not sure
	minimum = -32768,
	maximum = 32767,
	fuzz    = 16,
	flat    = 128,
}
HAT_ABSINFO :: uinput.Absinfo {
	minimum = -1,
	maximum = 1,
}
TRIGGER_ABSINFO :: uinput.Absinfo {
	minimum = 0,
	maximum = 255,
}
CONTROLLER_INPUTS :: uinput.Device_Init {
	abs  = []uinput.Abs_Setup {
		{code = .X, absinfo = STICK_ABSINFO},
		{code = .Y, absinfo = STICK_ABSINFO},
		{code = .Z, absinfo = TRIGGER_ABSINFO},
		{code = .RX, absinfo = STICK_ABSINFO},
		{code = .RY, absinfo = STICK_ABSINFO},
		{code = .RZ, absinfo = TRIGGER_ABSINFO},
		{code = .HAT0X, absinfo = HAT_ABSINFO},
		{code = .HAT0Y, absinfo = HAT_ABSINFO},
	},
	keys = []uinput.KEY {
		.BTN_NORTH,
		.BTN_SOUTH,
		.BTN_EAST,
		.BTN_WEST,
		.BTN_TL,
		.BTN_TR,
		.BTN_SELECT,
		.BTN_START,
		.BTN_MODE,
		.BTN_THUMBL,
		.BTN_THUMBR,
	},
}

// from https://unix.stackexchange.com/questions/742454/why-my-xbox360-wired-controller-disconnects-on-rumble
CONTROLLER_INPUT_ID :: uinput.Input_Id {
	bustype = 0x3,
	vendor  = 0x45e,
	product = 0x28e,
	version = 0x114,
}

create_player :: proc(addr: ^net.Address) {
	// FIXME: actually handle max players
	if player_count == len(players) do player_count -= 1

	setup := uinput.Setup {
		input_id       = CONTROLLER_INPUT_ID,
		ff_effects_max = 0,
	}
	copy(setup.name[:], CONTROLLER_NAME)
	setup.name[len(CONTROLLER_NAME)] = byte(player_count) + 'a'
	setup.name[len(CONTROLLER_NAME) + 1] = 0

	players[player_count] = Player {
		incremental = 0,
		addr        = addr^,
		device      = uinput.make_device(setup, CONTROLLER_INPUTS) or_else -1,
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
