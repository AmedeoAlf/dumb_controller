package controller

import "core:sys/linux"
import "uinput"

make :: proc(name: string) -> (controller: linux.Fd, error: linux.Errno) {
	setup := uinput.Setup {
		input_id       = CONTROLLER_INPUT_ID,
		ff_effects_max = 0,
	}
	copy(setup.name[:], name)

	return uinput.make_device(setup, CONTROLLER_INPUTS)
}

destroy :: proc(device: linux.Fd) {
	uinput.destroy_device(device)
}

filter_btns :: proc(state: ^Gamepad_State) {
	nums := transmute(Buttons_Underlying)state.buttons
	nums &= Buttons_Underlying((1 << len(Button)) - 1)
	state.buttons = transmute(bit_set[Button;Buttons_Underlying])nums
}

buttons_to_le :: proc(buttons: bit_set[Button;u16be]) -> bit_set[Button;u16] {
	return transmute(bit_set[Button;u16])u16(transmute(u16be)buttons)
}

handle_diff :: proc(controller: linux.Fd, prev: ^Gamepad_State, new: ^Gamepad_State) {
	// Some weird ass bug makes it need to be treated as little endian to work
	changed_btns := buttons_to_le(prev.buttons ~ new.buttons)
	for btn in changed_btns {
		key := _uinput_key_from_btn(btn)
		if key != nil do uinput.emit(controller, key, btn in new.buttons)
	}

	for val, axis in new.axes {
		if (prev.axes[axis] != val) {
			if code := _uinput_to_axis(axis); code != nil {
				uinput.emit_abs(controller, code, i32(val))
			}
		}
	}

	if (prev.hat.x != new.hat.x) do uinput.emit_abs(controller, .HAT0X, new.hat.x)
	if (prev.hat.y != new.hat.y) do uinput.emit_abs(controller, .HAT0Y, new.hat.y)

	uinput.report_0(controller)
	prev^ = new^
}

_uinput_key_from_btn :: proc(btn: Button) -> KEY {
	switch btn {
	case .SOUTH:
		return .BTN_SOUTH
	// XBOX One S controller reports
	// - 'X' (west) as north
	// - 'Y' (north) as west
	case .WEST:
		return .BTN_NORTH
	case .NORTH:
		return .BTN_WEST
	case .EAST:
		return .BTN_EAST
	case .START:
		return .BTN_START
	case .SELECT:
		return .BTN_SELECT
	case .LB:
		return .BTN_TL
	case .RB:
		return .BTN_TR
	case .LS:
		return .BTN_THUMBL
	case .RS:
		return .BTN_THUMBR
	case:
		return nil
	}
}

_uinput_to_axis :: proc(axis: Axis) -> ABS {
	switch axis {
	case .X:
		return .X
	case .Y:
		return .Y
	case .RX:
		return .RX
	case .RY:
		return .RY
	case:
		return nil
	}
}
