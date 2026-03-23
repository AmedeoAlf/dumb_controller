package dumb_controller

import "core:fmt"
import "core:os"

die :: proc(msg: any, code := -1, loc := #caller_location) {
	fmt.eprintln("FATAL:", loc, msg)
	os.exit(code)
}
