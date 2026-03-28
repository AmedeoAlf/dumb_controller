package controller

import "uinput"

CONTROLLER_NAME :: "dumb_controller "
STICK_ABSINFO :: uinput.Absinfo {
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
		.BTN_SOUTH,
		.BTN_EAST,
		.BTN_NORTH,
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

// from ./sunshine_controller_params.txt
CONTROLLER_INPUT_ID :: uinput.Input_Id {
	bustype = 0x3,
	vendor  = 0x45e,
	product = 0x2ea,
	version = 0x408,
}

KEY :: uinput.KEY
ABS :: uinput.ABS
REL :: uinput.REL
