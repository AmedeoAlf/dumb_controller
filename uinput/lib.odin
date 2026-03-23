package uinput

import "core:fmt"
import "core:mem"
import "core:sys/linux"

DEBUG :: false

dbg :: proc(val: $T) -> T {
	when DEBUG {
		fmt.eprintln(val)
	}
	return val
}

Input_Event :: struct {
	time:       linux.Time_Val,
	type, code: u16,
	value:      i32,
}

Input_Id :: struct {
	bustype, vendor, product, version: u16,
}

UINPUT_MAX_NAME_SIZE :: 80

iow :: proc "contextless" ($num: u32, $type: typeid) -> u32 {
	return (1 << 30) | ('U' << 8) | (num << 0) | (size_of(type) << 16)
}

IOW_INT_TOP_BITS :: (1 << 30) | ('U' << 8) | (size_of(i32) << 16)
IOW_PTR_TOP_BITS :: (1 << 30) | ('U' << 8) | (size_of(rawptr) << 16)

UI_SET :: enum u32 {
	EVBIT   = IOW_INT_TOP_BITS | 100,
	KEYBIT  = IOW_INT_TOP_BITS | 101,
	RELBIT  = IOW_INT_TOP_BITS | 102,
	ABSBIT  = IOW_INT_TOP_BITS | 103,
	MSCBIT  = IOW_INT_TOP_BITS | 104,
	LEDBIT  = IOW_INT_TOP_BITS | 105,
	SNDBIT  = IOW_INT_TOP_BITS | 106,
	FFBIT   = IOW_INT_TOP_BITS | 107,
	PHYS    = IOW_PTR_TOP_BITS | 108,
	SWBIT   = IOW_INT_TOP_BITS | 109,
	PROPBIT = IOW_INT_TOP_BITS | 110,
}

EV :: enum uintptr {
	SYN = 0x00,
	KEY = 0x01,
	REL = 0x02,
	ABS = 0x03,
	MSC = 0x04,
	SW = 0x05,
	LED = 0x11,
	SND = 0x12,
	REP = 0x14,
	FF = 0x15,
	PWR = 0x16,
	FF_STATUS = 0x17,
	MAX = 0x1f,
	CNT,
}

Setup :: struct {
	input_id:       Input_Id,
	name:           [UINPUT_MAX_NAME_SIZE]byte,
	ff_effects_max: u32,
}

Device_Init :: struct {
	keys: []KEY,
	rel:  []REL,
	abs:  []ABS,
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
	init_inputs(dev, .ABS, .ABSBIT, device_init.abs)

	linux.ioctl(dev, 3, uintptr(&usetup)) // UI_DEV_SETUP
	linux.ioctl(dev, 'u', 1) // UI_DEV_CREATE

	req := linux.Time_Spec {
		time_sec = 1,
	}
	linux.nanosleep(&req, nil)
	return
}

destroy_device :: proc(dev: linux.Fd) {
	linux.ioctl(dev, 'u', 2) // UI_DEV_DESTROY
	linux.close(dev)
}


emit_raw :: proc(dev: linux.Fd, #any_int type, code: u16, val: i32) {
	linux.write(dev, mem.any_to_bytes(Input_Event{type = type, code = code, value = val}))
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
