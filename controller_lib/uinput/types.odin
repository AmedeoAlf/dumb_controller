package uinput

import "core:sys/linux"

Input_Event :: struct {
	time:       linux.Time_Val,
	type, code: u16,
	value:      i32,
}

Input_Id :: struct {
	bustype, vendor, product, version: u16,
}

UINPUT_MAX_NAME_SIZE :: 80

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

Absinfo :: struct {
	value, minimum, maximum, fuzz, flat, resolution: i32,
}

Abs_Setup :: struct {
	code:    ABS,
	absinfo: Absinfo,
}

Device_Init :: struct {
	keys: []KEY,
	rel:  []REL,
	abs:  []Abs_Setup,
}
