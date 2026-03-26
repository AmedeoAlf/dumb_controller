package dumb_controller

import "controller_lib"
import "core:net"
import "core:sys/linux"

Packet_Type :: enum u8 {
	INPUT,
	PLAYER_NUM,
}

Input_Packet :: struct #packed {
	incremental: u32be,
	hash:        u32be,
	state:       controller_lib.Gamepad_State,
}

Player :: struct {
	using state: controller_lib.Gamepad_State,
	incremental: u32be,
	addr:        net.Address,
	device:      linux.Fd,
}
