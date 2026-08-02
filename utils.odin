package dumb_controller

import "core:fmt"
import "core:net"
import "core:os"

die :: proc(msg: any, code := -1, loc := #caller_location) {
	fmt.eprintln("FATAL:", loc, msg)
	os.exit(code)
}

// TODO: find better way
static_slice :: proc(arr: ^[$N]$T, $from: uint, $to: uint) -> [to - from]T {
	return (transmute(^[to - from]T)raw_data(arr[from:to]))^
}

print_ips :: proc() {
	// addrs, err := net.enumerate_interfaces()
	// fmt.println(addrs, err)
	ifaddrs: ^ifaddrs
	ifaddrs_err := getifaddrs(&ifaddrs)
	if ifaddrs_err != .NONE do return
	defer freeifaddrs(ifaddrs)

	for curr := ifaddrs; curr != nil; curr = curr.ifa_next {
		(.IFF_UP in curr.ifa_flags) or_continue
		(.IFF_LOOPBACK not_in curr.ifa_flags) or_continue
		addr: string
		#partial switch curr.ifa_addr.sa_family {
		case .INET:
			addr = net.address_to_string(
				net.IP4_Address(static_slice(&curr.ifa_addr.sa_data, 2, 6)),
			)
		case .INET6:
			addr = net.address_to_string(
				net.IP6_Address(static_slice(&curr.ifa_addr.sa_data, 2, 10)),
			)
		case:
			continue
		}
		fmt.printfln("{} -> {}", addr, curr.ifa_name)
	}
	free_all(context.temp_allocator)
}
