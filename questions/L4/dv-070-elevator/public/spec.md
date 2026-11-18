> Derived from the implementation; the original design intent has not been proven.

# top_module Elevator Control Specification (Derived from the Fixed Implementation)

### R-ELEV-001 — Frequency Division and Composition Boundaries

clk_divider is a free-running clock divider: it uses clk_in as the source clock and outputs a divided_clk square wave with a nominal frequency of approximately 50 Hz. The module contains no handshake, datapath, state machine, or memory; it is purely sequential counter-based frequency division. The upstream top_module uses the inverse of rst as its asynchronous reset and uses divided_clk as a 50 Hz clock to drive debouncer and elevator; these out-of-scope connections only explain its use, and their internal behavior is not proven here.

### R-ELEV-002 — Divider Interface Contract

The interface consists of three 1-bit ports, with no ready/valid or transaction semantics; the output free-runs solely with the source clock:

- clk_in (input, 1 bit): Divider source clock. All non-reset state updates occur on its rising edge.
- rst (input, 1 bit): Asynchronous, active-high reset. When rst is high, clearing to zero occurs immediately and asynchronously, without waiting for a clk_in edge.
- divided_clk (output, reg, 1 bit): Divided square-wave output, with an initial value of 0 after reset.

There are no “acceptance/completion” anchors: the divider accepts no commands and produces no acknowledgments; the other endpoint can only passively sample divided_clk.

### R-ELEV-003 — Divider Reset and Normal Mechanism

Reset: The always block is sensitive to posedge clk_in or posedge rst. When rst is high (asynchronously), cnt and divided_clk are set to 0 in the same cycle, so divided_clk is low after reset.

Normal counting and toggling: When rst is low, each clk_in rising edge samples the pre-edge cnt.

- If cnt is not equal to toggle_value: cnt increments by 1, and divided_clk holds (`divided_clk <= divided_clk` is a no-op that retains its own value).
- If cnt equals toggle_value: cnt returns to 0, and divided_clk is inverted.

Thus, divided_clk toggles once every (toggle_value+1) clk_in cycles: the half-period is (toggle_value+1) source cycles, the full period is 2*(toggle_value+1) source cycles, and the duty cycle is exactly 50%. With the default toggle_value=1000000, the half-period is 1000001 source cycles; with a 100 MHz source clock, the full period is approximately 20.00002 ms and the output is approximately 49.99995 Hz, approximately matching the header comment “divide by 1000000 to obtain 50 Hz”; the implemented division factor is 2*(toggle_value+1), rather than the literal 1000000 in the comment. It takes (toggle_value+1) rising edges from reset release to the first toggle.

### R-ELEV-004 — Divider State and Parameter Boundaries

State: The sole state register cnt is reg[24:0] (25-bit unsigned), with a value range of 0..33554431; divided_clk is 1 bit. There are no queues or memory arrays, hence no full/empty, backpressure, read/write conflict, or arbitration mechanisms.

Parameter: toggle_value is a 32-bit signed logic parameter with a default value of 1000000; this Job uses the RTL default parameters, with no parameter overrides provided.

Boundaries: cnt==toggle_value compares the 25-bit cnt against the 32-bit parameter. When 0 <= toggle_value <= 33554431, equality is reachable and toggling occurs normally; when toggle_value >= 33554432 (that is, 2^25), cnt reaches at most 33554431 before wrapping to 0 and never equals toggle_value, so divided_clk retains its initial value and stops toggling (constant low after reset). When toggle_value=0, the equality condition holds every source cycle, divided_clk toggles every cycle, and the output is clk_in divided by two. This comparison also triggers a SignCompare static warning (comparison of 25-bit unsigned cnt with a 32-bit signed parameter).

### R-ELEV-005 — Divider Issues and Risk Identification

- ISS-1 (parameter boundary, non-blocking): If toggle_value is set to >= 2^25, the 25-bit cnt cannot reach that value, and the output stops toggling. The default value 1000000 is within the valid range, so the default instance is unaffected; whether such overrides are permitted needs confirmation.
- ISS-2 (comment/implementation discrepancy, non-blocking): The header comment states “dividing the clock with 1000000”, while the actual division factor is 2*(toggle_value+1), with an offset introduced by +1 and toggling on both transitions; Section 3 already provides the exact formula based on the implementation. This is a documentation/implementation inconsistency rather than a functional defect.

### R-ELEV-006 — Top-Level Ports and Reset Polarity

The public DUT is `top_module`, not the standalone `clk_divider`. The top level uses `clk` as the seven-segment scan clock and uses `rst` as an active-low reset: `rst=0` means reset, and `rst=1` means normal operation. Internally, `~rst` is connected to the active-high resets of the divider, debouncer, elevator FSM, and seven-segment scanner. The divider, debouncer, and elevator FSM reset asynchronously, so a falling edge on the top-level `rst` immediately clears their states; the seven-segment scanner samples reset synchronously on the rising edge of `clk`, with `an=8'b11111111` after reset. Each of the five floors has an external call input `floor_n_p` and a car destination input `floor_n_d`; floors 1 through 3 additionally have direction inputs `direction_1..3`, floor 4 is fixed downward, and floor 0 is fixed upward. Outputs include five car destination LED bits, five external call LED bits, `led_busy`, eight sets of seven-segment codes, and the eight-bit scan selection `an`.



### R-ELEV-007 — Elevator State, Request Acceptance, and Movement

Reset asynchronously clears the internal target floor, current floor, and LEDs, and enters the idle state; the current floor starts at 0. Requests are checked in floor-priority order on internal 50 Hz clock edges; requests serviceable in the current movement direction can be saved as the current target or inserted as a target; same-floor requests do not cause movement. In the idle state, a target floor greater than the current floor causes entry into upward movement, and a smaller one causes entry into downward movement; each transition between floors requires `toggleValue=250` internal counting cycles. At a stop, `led_busy` is active during the door-count window; when counting ends, the corresponding destination/call LEDs are cleared, and movement or idle resumes. The legal floor range is 0..4; other internal floor encodings fall back to the floor 0 pattern in display decoding.



### R-ELEV-008 — Seven-Segment Scanning and Implementation Diagnostics

`ssd` cyclically scans eight display digits in the `clk` domain; the elevator state and current floor generate segment codes for direction, floor, and idle/busy status, and `top_module` directly forwards the segment codes and `an`. The candidate interacts only through the native ports of `top_module` and must not replace internal clocks or counters. Strict cycle-by-cycle differences in the divider default parameters and seven-segment scan constants are listed separately as implementation-consistency diagnostics.




## Native Port Behavior Supplement

The following supplements the external connection semantics that originally required reading the implementation to determine; it retains R-ELEV-006/007/008 and adds no obligation for hidden internal probing. Only the default configuration is allowed; internal parameters cannot be overridden from the top level.

External call floor_n_p produces a single-cycle rising pulse through an internal sampling chain; starting with the input held continuously high after reset, the third derived rising edge generates this pulse, and downstream logic sees it on the fourth derived rising edge. Car floor_n_d directly samples the level on derived edges. All derived edges are inferred from the top-level clk/rst history. The request selection priority is floors 1, 2, 3, 4, 0; when multiple requests occur simultaneously, only one floor is selected first; direction_n for floors 1..3 applies to both types of requests for that floor, and 1 means upward. When a request for a different floor is accepted, both the inside/outside LEDs for that floor turn on simultaneously; upon reaching that floor, both are cleared simultaneously. While moving upward, only insertion requests strictly between the current floor and the original target floor and with upward direction are accepted; downward movement is symmetric. Neither holding a request level nor withdrawing a request constitutes a new ready/ack handshake.

The seven-segment outputs represent seven-bit active-low segment codes in the order a_out,b_out,c_out,d_out,e_out,f_out,g_out, with p_out being 1. At position 0, floors 0..4 are respectively 0000001, 1001111, 0010010, 0000110, 1001100; position 1 is 1111110, position 2 is 1110001, position 3 is 0111000, and positions 6/7 are 1111110. Positions 5/4 are 1001111/1000010 when idle, 1000001/0011000 when moving upward, and 1000010/1100010 when moving downward. After reset spans a main clk rising edge, an=ff and all segment outputs are 1. Normal scanning selects an=fe,fd,fb,f7,ef,df,bf,7f in sequence; each position nominally holds for 100001 main clk cycles, and the first selection appears on the 100002nd rising edge after reset release. The strict scan period is within the existing implementation diagnostic scope and must not be added as an undeclared grading obligation.
