# Features

## local-1

['R-ELEV-001']
top_module
clk_divider is a free-running clock divider: it uses clk_in as the source clock and outputs a divided_clk square wave with a nominal frequency of approximately 50 Hz. The module contains no handshake, datapath, state machine, or memory; it is purely sequential counter-based frequency division. The upstream top_module uses the inverse of rst as its asynchronous reset and uses divided_clk as a 50 Hz clock to drive debouncer and elevator; these out-of-scope connections only explain its use, and their internal behavior is not proven here.
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst']

## local-2

['R-ELEV-002']
top_module
The interface consists of three 1-bit ports, with no ready/valid or transaction semantics; the output free-runs solely with the source clock:

- clk_in (input, 1 bit): Divider source clock. All non-reset state updates occur on its rising edge.
- rst (input, 1 bit): Asynchronous, active-high reset. When rst is high, clearing to zero occurs immediately and asynchronously, without waiting for a clk_in edge.
- divided_clk (output, reg, 1 bit): Divided square-wave output, with an initial value of 0 after reset.

There are no “acceptance/completion” anchors: the divider accepts no commands and produces no acknowledgments; the other endpoint can only passively sample divided_clk.
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst']

## local-3

['R-ELEV-003']
top_module
Reset: The always block is sensitive to posedge clk_in or posedge rst. When rst is high (asynchronously), cnt and divided_clk are set to 0 in the same cycle, so divided_clk is low after reset.

Normal counting and toggling: When rst is low, each clk_in rising edge samples the pre-edge cnt.

- If cnt is not equal to toggle_value: cnt increments by 1, and divided_clk holds (`divided_clk <= divided_clk` is a no-op that retains its own value).
- If cnt equals toggle_value: cnt returns to 0, and divided_clk is inverted.

Thus, divided_clk toggles once every (toggle_value+1) clk_in cycles: the half-period is (toggle_value+1) source cycles, the full period is 2*(toggle_value+1) source cycles, and the duty cycle is exactly 50%. With the default toggle_value=1000000, the half-period is 1000001 source cycles; with a 100 MHz source clock, the full period is approximately 20.00002 ms and the output is approximately 49.99995 Hz, approximately matching the header comment “divide by 1000000 to obtain 50 Hz”; the implemented division factor is 2*(toggle_value+1), rather than the literal 1000000 in the comment. It takes (toggle_value+1) rising edges from reset release to the first toggle.
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst']

## local-4

['R-ELEV-004']
top_module
State: The sole state register cnt is reg[24:0] (25-bit unsigned), with a value range of 0..33554431; divided_clk is 1 bit. There are no queues or memory arrays, hence no full/empty, backpressure, read/write conflict, or arbitration mechanisms.

Parameter: toggle_value is a 32-bit signed logic parameter with a default value of 1000000; this Job uses the RTL default parameters, with no parameter overrides provided.

Boundaries: cnt==toggle_value compares the 25-bit cnt against the 32-bit parameter. When 0 <= toggle_value <= 33554431, equality is reachable and toggling occurs normally; when toggle_value >= 33554432 (that is, 2^25), cnt reaches at most 33554431 before wrapping to 0 and never equals toggle_value, so divided_clk retains its initial value and stops toggling (constant low after reset). When toggle_value=0, the equality condition holds every source cycle, divided_clk toggles every cycle, and the output is clk_in divided by two. This comparison also triggers a SignCompare static warning (comparison of 25-bit unsigned cnt with a 32-bit signed parameter).
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst']

## local-5

['R-ELEV-005']
top_module
- ISS-1 (parameter boundary, non-blocking): If toggle_value is set to >= 2^25, the 25-bit cnt cannot reach that value, and the output stops toggling. The default value 1000000 is within the valid range, so the default instance is unaffected; whether such overrides are permitted needs confirmation.
- ISS-2 (comment/implementation discrepancy, non-blocking): The header comment states “dividing the clock with 1000000”, while the actual division factor is 2*(toggle_value+1), with an offset introduced by +1 and toggling on both transitions; Section 3 already provides the exact formula based on the implementation. This is a documentation/implementation inconsistency rather than a functional defect.
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst']

## local-6

['R-ELEV-006']
top_module
The public DUT is `top_module`, not the standalone `clk_divider`. The top level uses `clk` as the seven-segment scan clock and uses `rst` as an active-low reset: `rst=0` means reset, and `rst=1` means normal operation. Internally, `~rst` is connected to the active-high resets of the divider, debouncer, elevator FSM, and seven-segment scanner. The divider, debouncer, and elevator FSM reset asynchronously, so a falling edge on the top-level `rst` immediately clears their states; the seven-segment scanner samples reset synchronously on the rising edge of `clk`, with `an=8'b11111111` after reset. Each of the five floors has an external call input `floor_n_p` and a car destination input `floor_n_d`; floors 1 through 3 additionally have direction inputs `direction_1..3`, floor 4 is fixed downward, and floor 0 is fixed upward. Outputs include five car destination LED bits, five external call LED bits, `led_busy`, eight sets of seven-segment codes, and the eight-bit scan selection `an`.

Evidence: `rtl/top_module.v:4-68`, `rtl/elevator.v:3-44`, `solution/reference/tb_top.sv:15-35`.
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst', 'floor_0_p', 'floor_1_p', 'floor_2_p', 'floor_3_p', 'floor_4_p', 'floor_0_d', 'floor_1_d', 'floor_2_d', 'floor_3_d', 'floor_4_d', 'direction_1', 'direction_2', 'direction_3', 'led_inside_0', 'led_inside_1', 'led_inside_2', 'led_inside_3', 'led_inside_4', 'led_outside_0', 'led_outside_1', 'led_outside_2', 'led_outside_3', 'led_outside_4', 'led_busy', 'a_out', 'b_out', 'c_out', 'd_out', 'e_out', 'f_out', 'g_out', 'p_out', 'an']

## local-7

['R-ELEV-007']
top_module
Reset asynchronously clears the internal target floor, current floor, and LEDs, and enters the idle state; the current floor starts at 0. Requests are checked in floor-priority order on internal 50 Hz clock edges; requests serviceable in the current movement direction can be saved as the current target or inserted as a target; same-floor requests do not cause movement. In the idle state, a target floor greater than the current floor causes entry into upward movement, and a smaller one causes entry into downward movement; each transition between floors requires `toggleValue=250` internal counting cycles. At a stop, `led_busy` is active during the door-count window; when counting ends, the corresponding destination/call LEDs are cleared, and movement or idle resumes. The legal floor range is 0..4; other internal floor encodings fall back to the floor 0 pattern in display decoding.

Evidence: `rtl/elevator.v:47-65`, `rtl/elevator.v:221-238`, `rtl/elevator.v:240-514`, `solution/reference/elev_pkg.sv:199-318`.
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst', 'floor_0_p', 'floor_1_p', 'floor_2_p', 'floor_3_p', 'floor_4_p', 'floor_0_d', 'floor_1_d', 'floor_2_d', 'floor_3_d', 'floor_4_d', 'direction_1', 'direction_2', 'direction_3', 'led_inside_0', 'led_inside_1', 'led_inside_2', 'led_inside_3', 'led_inside_4', 'led_outside_0', 'led_outside_1', 'led_outside_2', 'led_outside_3', 'led_outside_4', 'led_busy', 'a_out', 'b_out', 'c_out', 'd_out', 'e_out', 'f_out', 'g_out', 'p_out', 'an']

## local-8

['R-ELEV-008']
top_module
`ssd` cyclically scans the eight-digit seven-segment display in the `clk` domain; the elevator state and current floor generate segment codes for direction, floor, and idle/busy status, and `top_module` directly forwards the segment codes and `an`. The fixed reference TB uses `force/release` to replace internal clocks and long counters to shorten runtime. This is an implementation diagnostic for the hidden reference and must not be treated as a candidate port contract or a public behavioral requirement; candidates must interact only through the `top_module` ports. Strict cycle-by-cycle differences in the clock divider's default parameters and the seven-segment scan constants are listed separately as implementation-consistency diagnostics.

Evidence: `rtl/top_module.v:48-68`, `rtl/ssd.v`, `solution/reference/tb_top.sv:37-132`.
Timing and sampling follow the explicit description in definition; there are no additional clock or latency assumptions.
The applicable domain and undefined scope follow the explicit description in definition, without further restricting legal inputs.
['clk', 'rst', 'a_out', 'b_out', 'c_out', 'd_out', 'e_out', 'f_out', 'g_out', 'p_out', 'an']