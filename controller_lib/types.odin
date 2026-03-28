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

Buttons_Underlying :: u16be
Gamepad_State :: struct {
	buttons: bit_set[Button;Buttons_Underlying],
	// TODO: add sticks
}
