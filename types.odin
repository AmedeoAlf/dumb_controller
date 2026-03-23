package dumb_controller

import "core:net"
import "core:sys/linux"

Button :: enum {
	SOUTH,
	WEST,
	EAST,
	NORTH,
	START,
	SELECT,
	LB,
	RB,
	LT,
	RT,
	LS,
	RS,
}

Packet_Type :: enum u8 {
	INPUT,
	PLAYER_NUM,
}

Buttons_Underlying :: u16be
Gamepad_State :: struct {
	buttons: bit_set[Button;Buttons_Underlying],
	// TODO: add sticks
}

Input_Packet :: struct #packed {
	incremental: u32be,
	hash:        u32be,
	state:       Gamepad_State,
}

Player :: struct {
	using state: Gamepad_State,
	incremental: u32be,
	addr:        net.Address,
	device:      linux.Fd,
}
