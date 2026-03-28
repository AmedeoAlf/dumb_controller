package tester

import ".."
import "core:fmt"
import "core:time"

main :: proc() {
	controller, err := controller_lib.make("GAY")
	fmt.eprintln(err)

	time.sleep(time.Second)

	state := controller_lib.Gamepad_State{}

	target := []controller_lib.Gamepad_State{{buttons = {.START}}, {buttons = {.SELECT}}}

	for i in 0 ..< 4 {
		for &t in target {
			time.sleep(time.Second)
			controller_lib.handle_diff(controller, &state, &t)
		}
	}

}
