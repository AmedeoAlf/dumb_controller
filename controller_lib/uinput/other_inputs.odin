package uinput

REL :: enum u16 {
	X = 0x00,
	Y = 0x01,
	Z = 0x02,
	RX = 0x03,
	RY = 0x04,
	RZ = 0x05,
	HWHEEL = 0x06,
	DIAL = 0x07,
	WHEEL = 0x08,
	MISC = 0x09,
	RESERVED = 0x0a,
	WHEEL_HI_RES = 0x0b,
	HWHEEL_HI_RES = 0x0c,
	MAX = 0x0f,
	CNT,
}

ABS :: enum u16 {
	X = 0x00,
	Y = 0x01,
	Z = 0x02,
	RX = 0x03,
	RY = 0x04,
	RZ = 0x05,
	THROTTLE = 0x06,
	RUDDER = 0x07,
	WHEEL = 0x08,
	GAS = 0x09,
	BRAKE = 0x0a,
	HAT0X = 0x10,
	HAT0Y = 0x11,
	HAT1X = 0x12,
	HAT1Y = 0x13,
	HAT2X = 0x14,
	HAT2Y = 0x15,
	HAT3X = 0x16,
	HAT3Y = 0x17,
	PRESSURE = 0x18,
	DISTANCE = 0x19,
	TILT_X = 0x1a,
	TILT_Y = 0x1b,
	TOOL_WIDTH = 0x1c,
	VOLUME = 0x20,
	PROFILE = 0x21,
	SND_PROFILE = 0x22,
	MISC = 0x28,

	/*
 * 0x2e is reserved and should not be used in input drivers.
 * It was used by HID as MISC+6 and userspace needs to detect if
 * the next * event is correct or is just ABS_MISC + n.
 * We define here RESERVED so userspace can rely on it and detect
 * the situation described above.
 */
	RESERVED = 0x2e,
	MT_SLOT = 0x2f, /* MT slot being modified */
	MT_TOUCH_MAJOR = 0x30, /* Major axis of touching ellipse */
	MT_TOUCH_MINOR = 0x31, /* Minor axis (omit if circular) */
	MT_WIDTH_MAJOR = 0x32, /* Major axis of approaching ellipse */
	MT_WIDTH_MINOR = 0x33, /* Minor axis (omit if circular) */
	MT_ORIENTATION = 0x34, /* Ellipse orientation */
	MT_POSITION_X = 0x35, /* Center X touch position */
	MT_POSITION_Y = 0x36, /* Center Y touch position */
	MT_TOOL_TYPE = 0x37, /* Type of touching device */
	MT_BLOB_ID = 0x38, /* Group a set of packets as a blob */
	MT_TRACKING_ID = 0x39, /* Unique ID of initiated contact */
	MT_PRESSURE = 0x3a, /* Pressure on contact area */
	MT_DISTANCE = 0x3b, /* Contact hover distance */
	MT_TOOL_X = 0x3c, /* Center X tool position */
	MT_TOOL_Y = 0x3d, /* Center Y tool position */
	MAX = 0x3f,
	CNT,
}

SYN :: enum u16 {
	REPORT = 0,
	CONFIG = 1,
	MT_REPORT = 2,
	DROPPED = 3,
	MAX = 0xf,
	CNT,
}
