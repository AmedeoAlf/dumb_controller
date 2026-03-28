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

Hat :: enum u8 {
	MID,
	MIDL,
	MIDR,
	TOP,
	TOPL,
	TOPR,
	BOT,
	BOTL,
	BOTR,
}

Buttons_Underlying :: u16be
Gamepad_State :: struct #packed {
	buttons: bit_set[Button;Buttons_Underlying],
	axes:    [Axis]i16,
	hat:     Hat,
}
