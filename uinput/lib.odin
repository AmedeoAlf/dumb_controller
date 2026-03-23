package uinput

import "core:fmt"
import "core:mem"
import "core:sys/linux"

DEBUG :: true

dbg :: proc(val: $T) -> T {
	when DEBUG {
		fmt.eprintln(val)
	}
	return val
}

// from https://docs.kernel.org/input/uinput.html
make_device :: proc(usetup: Setup, device_init: Device_Init) -> (dev: linux.Fd, err: linux.Errno) {
	usetup := usetup
	dev = linux.open("/dev/uinput", {.WRONLY, .NONBLOCK}) or_return

	init_inputs :: proc(dev: linux.Fd, event: EV, individual: UI_SET, list: []$T) {
		if len(list) == 0 do return
		linux.ioctl(dev, u32(UI_SET.EVBIT), uintptr(event))
		for input in list {
			linux.ioctl(dev, u32(individual), uintptr(input))
		}
	}

	init_inputs(dev, .KEY, .KEYBIT, device_init.keys)
	init_inputs(dev, .REL, .RELBIT, device_init.rel)

	linux.ioctl(dev, u32(UI_SET.EVBIT), uintptr(EV.ABS))
	for &abs in device_init.abs {
		linux.ioctl(dev, u32(UI_SET.ABSBIT), uintptr(abs.code))
		linux.ioctl(dev, 0x401c5504, uintptr(&abs)) // UI_ABS_SETUP
	}

	linux.ioctl(dev, 0x405c5503, uintptr(&usetup)) // UI_DEV_SETUP
	linux.ioctl(dev, 0x5501, 0) // UI_DEV_CREATE

	req := linux.Time_Spec {
		time_sec = 1,
	}
	linux.nanosleep(&req, nil)
	return
}

destroy_device :: proc(dev: linux.Fd) {
	linux.ioctl(dev, 0x5502, 2) // UI_DEV_DESTROY
	linux.close(dev)
}


emit_raw :: proc(dev: linux.Fd, #any_int type, code: u16, val: i32) {
	_, errno := linux.write(
		dev,
		mem.any_to_bytes(Input_Event{type = type, code = code, value = val}),
	)
	if errno != .NONE do dbg(errno)
}

emit_key :: proc(dev: linux.Fd, key: KEY, pressed: b32) {
	emit_raw(dev, EV.KEY, key, i32(pressed))
}

emit_rel :: proc(dev: linux.Fd, rel: REL, val: i32) {
	emit_raw(dev, EV.REL, rel, val)
}

emit_abs :: proc(dev: linux.Fd, abs: ABS, val: i32) {
	emit_raw(dev, EV.ABS, abs, val)
}

emit_syn :: proc(dev: linux.Fd, syn: SYN, val: i32) {
	emit_raw(dev, EV.SYN, syn, val)
}

report_0 :: proc(dev: linux.Fd) {
	emit_syn(dev, .REPORT, 0)
}

emit :: proc {
	emit_raw,
	emit_key,
	emit_rel,
	emit_syn,
	report_0,
}
