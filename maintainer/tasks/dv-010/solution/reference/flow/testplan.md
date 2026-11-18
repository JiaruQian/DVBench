# Reference testplan

## T1

feature_ids: ['F1']

requirement_ids: ['R-p8-hpa-001']

stimulus: After acquiring each owner in turn using a valid ready accepted nonlast beat, assert reset across a rising edge with both valids and ready high. Also pulse reset between edges and clear before the next edge while each owner is active. Include reset with no ownership.

expected: The only clock is clock. A rising edge with reset=1 discards any packet ownership and returns to unlocked arbitration, taking priority over an otherwise accepted beat. Reset is active high and synchronous: changing reset between rising edges does not itself alter ownership. Outputs remain combinational during reset and are not forced low. Apply at least one reset edge before observing specified behavior; power-up state before that edge is unspecified.

checker: Independent dvbench_model predicts from input history and reset only. hpa_monitor observes all native outputs and separate model outputs two time units after each falling and rising clock edge; hpa_scoreboard uses four-state inequality, emits UVM_ERROR on any mismatch, counts samples and rejects fewer than 100 observations. Invalid-cycle combinational fields are also checked. The synchronous-reset short pulse is sampled between edges while ownership remains active.

implementation_id: hpa_scoreboard.write

source: hpa_pkg.sv:hpa_sequence.body; hpa_monitor.capture; hpa_scoreboard.write

## T2

feature_ids: ['F2']

requirement_ids: ['R-p8-hpa-002']

stimulus: Starting after a reset edge, apply all four valid combinations crossed with both downstream ready values and both last values. Use distinct payloads on the two inputs. Change inputs at a falling edge and observe settled combinational outputs before the next rising edge.

expected: When no packet owns the arbiter, input 1 is selected whenever io_in_1_valid=1; otherwise input 4 is selected, including when both valids are zero. Thus input 1 wins simultaneous requests. io_out_valid equals the selected input valid, independently of io_out_ready. The selected input ready equals io_out_ready and the other ready is zero, even when the selected valid is zero. Selection and ready/valid respond combinationally with no registered data latency.

checker: Independent dvbench_model predicts from input history and reset only. hpa_monitor observes all native outputs and separate model outputs two time units after each falling and rising clock edge; hpa_scoreboard uses four-state inequality, emits UVM_ERROR on any mismatch, counts samples and rejects fewer than 100 observations. Invalid-cycle combinational fields are also checked. The synchronous-reset short pulse is sampled between edges while ownership remains active.

implementation_id: hpa_scoreboard.write

source: hpa_pkg.sv:hpa_sequence.body; hpa_monitor.capture; hpa_scoreboard.write

## T3

feature_ids: ['F3']

requirement_ids: ['R-p8-hpa-003']

stimulus: Prepare unlocked, input1-owned and input4-owned states independently. In each state drive all 32 combinations of v1,v4,ready,last1,last4, including accepted last and nonlast beats, then offer both inputs with last=1 and ready=1 to observe post-release priority.

expected: A beat is accepted at a rising edge exactly when io_out_ready and the selected input valid are both one. An accepted beat whose selected last bit is zero grants or retains packet ownership for that input. An accepted beat whose last bit is one releases ownership after that edge, allowing unlocked priority selection immediately thereafter. The beat being accepted uses the ownership and selection that existed before the edge. A one-beat packet does not leave ownership active.

checker: Independent dvbench_model predicts from input history and reset only. hpa_monitor observes all native outputs and separate model outputs two time units after each falling and rising clock edge; hpa_scoreboard uses four-state inequality, emits UVM_ERROR on any mismatch, counts samples and rejects fewer than 100 observations. Invalid-cycle combinational fields are also checked. The synchronous-reset short pulse is sampled between edges while ownership remains active.

implementation_id: hpa_scoreboard.write

source: hpa_pkg.sv:hpa_sequence.body; hpa_monitor.capture; hpa_scoreboard.write

## T4

feature_ids: ['F4']

requirement_ids: ['R-p8-hpa-004']

stimulus: Acquire ownership for each input. Withdraw owner valid while competitor stays valid; vary both last bits, then stall ready while last toggles. Resume owner and terminate the packet. Cross both input valids with downstream ready and both lasts in each ownership state.

expected: Without an accepted beat, ownership does not change, regardless of either last bit. While owned, the same input stays selected even if its valid becomes zero or the competing input becomes valid. A paused owner therefore yields io_out_valid=0, while its ready still follows io_out_ready and the competing ready stays zero. Backpressure io_out_ready=0 forces both ready outputs low and cannot acquire, release, or switch ownership. Payload is not buffered by this module; current selected input fields remain the source of the combinational outputs.

checker: Independent dvbench_model predicts from input history and reset only. hpa_monitor observes all native outputs and separate model outputs two time units after each falling and rising clock edge; hpa_scoreboard uses four-state inequality, emits UVM_ERROR on any mismatch, counts samples and rejects fewer than 100 observations. Invalid-cycle combinational fields are also checked. The synchronous-reset short pulse is sampled between edges while ownership remains active.

implementation_id: hpa_scoreboard.write

source: hpa_pkg.sv:hpa_sequence.body; hpa_monitor.capture; hpa_scoreboard.write

## T5

feature_ids: ['F5']

requirement_ids: ['R-p8-hpa-005']

stimulus: Use random independent full-width payloads on both inputs during every directed control combination and 1000 further seeded random cycles. Include both selected channels, idle selections, stalls and packets; vary every field and address independently across zero, ones, contrasting and seeded random values.

expected: For a selected input, opcode, param, size, source, data, corrupt, union and last pass through to the corresponding io_out_bits fields without arithmetic, truncation or registration. Selection of input 1 produces io_out_bits_chanId=3 and io_out_bits_address=0; selection of input 4 produces io_out_bits_chanId=0 and forwards io_in_4_bits_address. Every bit pattern in each declared field is in scope. These combinational values are defined even when io_out_valid=0, after a reset edge has initialized ownership.

checker: Independent dvbench_model predicts from input history and reset only. hpa_monitor observes all native outputs and separate model outputs two time units after each falling and rising clock edge; hpa_scoreboard uses four-state inequality, emits UVM_ERROR on any mismatch, counts samples and rejects fewer than 100 observations. Invalid-cycle combinational fields are also checked. The synchronous-reset short pulse is sampled between edges while ownership remains active.

implementation_id: hpa_scoreboard.write

source: hpa_pkg.sv:hpa_sequence.body; hpa_monitor.capture; hpa_scoreboard.write
