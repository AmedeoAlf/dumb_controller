package controller

Button :: enum {
	SOUTH,
	WEST,
	EAST,
	NORTH,
	START,
	SELECT,
	LB,
	RB,
	LS,
	RS,
}

Axis :: enum {
	X,
	Y,
	RX,
	RY,
}

Hat :: bit_field u8 {
	x: i32 | 2,
	y: i32 | 2,
}

Buttons_Underlying :: u16be
Gamepad_State :: struct #packed {
	buttons: bit_set[Button;Buttons_Underlying],
	axes:    [Axis]i16,
	hat:     Hat,
}
