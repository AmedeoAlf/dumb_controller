package mouse_lib

import "../controller_lib/uinput"
import "core:sys/linux"

make_mouse :: proc() -> (mouse: linux.Fd, err: linux.Errno) {
	setup := uinput.Setup {
		input_id = {
			bustype = 0x3, // BUS_USB
			vendor  = 0x1234, // sample vendor
			product = 0x5678, // sample product
		},
		ff_effects_max = 0,
	}
	copy(setup.name[:], "dumb controller mouse")

	return uinput.make_device(
		setup,
		uinput.Device_Init{rel = []uinput.REL{.X, .Y}},
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
