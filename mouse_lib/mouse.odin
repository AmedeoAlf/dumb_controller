package mouse_lib

import "../controller_lib/uinput"
import "core:sys/linux"

make_mouse :: proc() -> (mouse: linux.Fd, err: linux.Errno) {
	// Input device ID: bus 0x3 vendor 0x1bcf product 0x53 version 0x110
	setup := uinput.Setup {
		input_id = {
			bustype = 0x3, // BUS_USB
			vendor  = 0x1bcf, // sample vendor
			product = 0x53, // sample product
			version = 0x110,
		},
	}
	copy(setup.name[:], "dumb controller mouse")

	return uinput.make_device(
		setup,
		uinput.Device_Init {
			rel = []uinput.REL{.X, .Y},
			keys = []uinput.KEY{.BTN_LEFT, .BTN_RIGHT},
		},
	)
}

destroy_mouse :: proc(mouse: linux.Fd) {
	uinput.destroy_device(mouse)
}

move_mouse :: proc(mouse: linux.Fd, x, y: i32) {
	uinput.emit_rel(mouse, .X, x)
	uinput.emit_rel(mouse, .Y, y)
	uinput.report_0(mouse)
}

MouseBtn :: enum {
	LEFT,
	RIGHT,
}

MousePacket :: struct #packed {
	offset: [2]i16be,
	btns:   bit_set[MouseBtn;u8],
}

emit_btn :: proc(mouse: linux.Fd, btn: MouseBtn, pressed: b32) {
	uinput_code: uinput.KEY
	switch btn {
	case .LEFT:
		uinput_code = .BTN_LEFT
	case .RIGHT:
		uinput_code = .BTN_RIGHT
	case:
		panic("invalid button emitted on mouse")
	}
	uinput.emit_key(mouse, uinput_code, pressed)
	uinput.report_0(mouse)
}
