package dumb_controller

import "controller_lib"
import "core:net"
import "core:sys/linux"
import "mouse_lib"

Packet_Type :: enum u8 {
	INPUT,
	PLAYER_NUM,
	BROADCAST,
}

Input_Packet :: struct #packed {
	incremental: u32be,
	hash:        u32be,
	gamepad:     controller_lib.Gamepad_State,
	mouse:       mouse_lib.MousePacket,
}

Player :: struct {
	using gamepad: controller_lib.Gamepad_State,
	mouse_btns:    bit_set[mouse_lib.MouseBtn;u8],
	incremental:   u32be,
	addr:          net.Address,
	device:        linux.Fd,
	// shared between all
	mouse_dev:     linux.Fd,
}
