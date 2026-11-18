# Reference features

## F1

requirement_ids: ['R-p8-hpa-001']

module: HellaPeekingArbiter

definition: The only clock is clock. A rising edge with reset=1 discards any packet ownership and returns to unlocked arbitration, taking priority over an otherwise accepted beat. Reset is active high and synchronous: changing reset between rising edges does not itself alter ownership. Outputs remain combinational during reset and are not forced low. Apply at least one reset edge before observing specified behavior; power-up state before that edge is unspecified.

interface: ['clock', 'reset', 'io_in_1_valid', 'io_in_4_valid', 'io_out_ready', 'io_in_1_ready', 'io_in_4_ready', 'io_out_valid', 'io_in_1_bits_last', 'io_in_4_bits_last']

timing: Native outputs follow current selected inputs combinationally; ownership updates on rising clock edges only, with synchronous reset priority.

boundary: All binary field patterns; both unlocked and both reachable owner states; invalid and stalled cycles remain in scope.

## F2

requirement_ids: ['R-p8-hpa-002']

module: HellaPeekingArbiter

definition: When no packet owns the arbiter, input 1 is selected whenever io_in_1_valid=1; otherwise input 4 is selected, including when both valids are zero. Thus input 1 wins simultaneous requests. io_out_valid equals the selected input valid, independently of io_out_ready. The selected input ready equals io_out_ready and the other ready is zero, even when the selected valid is zero. Selection and ready/valid respond combinationally with no registered data latency.

interface: ['clock', 'reset', 'io_in_1_valid', 'io_in_4_valid', 'io_out_ready', 'io_in_1_ready', 'io_in_4_ready', 'io_out_valid']

timing: Native outputs follow current selected inputs combinationally; ownership updates on rising clock edges only, with synchronous reset priority.

boundary: All binary field patterns; both unlocked and both reachable owner states; invalid and stalled cycles remain in scope.

## F3

requirement_ids: ['R-p8-hpa-003']

module: HellaPeekingArbiter

definition: A beat is accepted at a rising edge exactly when io_out_ready and the selected input valid are both one. An accepted beat whose selected last bit is zero grants or retains packet ownership for that input. An accepted beat whose last bit is one releases ownership after that edge, allowing unlocked priority selection immediately thereafter. The beat being accepted uses the ownership and selection that existed before the edge. A one-beat packet does not leave ownership active.

interface: ['clock', 'io_in_1_valid', 'io_in_4_valid', 'io_out_ready', 'io_in_1_ready', 'io_in_4_ready', 'io_out_valid', 'io_in_1_bits_last', 'io_in_4_bits_last']

timing: Native outputs follow current selected inputs combinationally; ownership updates on rising clock edges only, with synchronous reset priority.

boundary: All binary field patterns; both unlocked and both reachable owner states; invalid and stalled cycles remain in scope.

## F4

requirement_ids: ['R-p8-hpa-004']

module: HellaPeekingArbiter

definition: Without an accepted beat, ownership does not change, regardless of either last bit. While owned, the same input stays selected even if its valid becomes zero or the competing input becomes valid. A paused owner therefore yields io_out_valid=0, while its ready still follows io_out_ready and the competing ready stays zero. Backpressure io_out_ready=0 forces both ready outputs low and cannot acquire, release, or switch ownership. Payload is not buffered by this module; current selected input fields remain the source of the combinational outputs.

interface: ['clock', 'reset', 'io_in_1_valid', 'io_in_4_valid', 'io_out_ready', 'io_in_1_ready', 'io_in_4_ready', 'io_out_valid', 'io_in_1_bits_last', 'io_in_4_bits_last']

timing: Native outputs follow current selected inputs combinationally; ownership updates on rising clock edges only, with synchronous reset priority.

boundary: All binary field patterns; both unlocked and both reachable owner states; invalid and stalled cycles remain in scope.

## F5

requirement_ids: ['R-p8-hpa-005']

module: HellaPeekingArbiter

definition: For a selected input, opcode, param, size, source, data, corrupt, union and last pass through to the corresponding io_out_bits fields without arithmetic, truncation or registration. Selection of input 1 produces io_out_bits_chanId=3 and io_out_bits_address=0; selection of input 4 produces io_out_bits_chanId=0 and forwards io_in_4_bits_address. Every bit pattern in each declared field is in scope. These combinational values are defined even when io_out_valid=0, after a reset edge has initialized ownership.

interface: ['clock', 'reset', 'io_in_1_ready', 'io_in_1_valid', 'io_in_1_bits_opcode', 'io_in_1_bits_param', 'io_in_1_bits_size', 'io_in_1_bits_source', 'io_in_1_bits_data', 'io_in_1_bits_corrupt', 'io_in_1_bits_union', 'io_in_1_bits_last', 'io_in_4_ready', 'io_in_4_valid', 'io_in_4_bits_opcode', 'io_in_4_bits_param', 'io_in_4_bits_size', 'io_in_4_bits_source', 'io_in_4_bits_address', 'io_in_4_bits_data', 'io_in_4_bits_corrupt', 'io_in_4_bits_union', 'io_in_4_bits_last', 'io_out_ready', 'io_out_valid', 'io_out_bits_chanId', 'io_out_bits_opcode', 'io_out_bits_param', 'io_out_bits_size', 'io_out_bits_source', 'io_out_bits_address', 'io_out_bits_data', 'io_out_bits_corrupt', 'io_out_bits_union', 'io_out_bits_last']

timing: Native outputs follow current selected inputs combinationally; ownership updates on rising clock edges only, with synchronous reset priority.

boundary: All binary field patterns; both unlocked and both reachable owner states; invalid and stalled cycles remain in scope.
