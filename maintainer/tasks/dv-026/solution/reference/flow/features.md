# features

## F1

feature_id: F1

requirement_ids: ["R-dv-026-001"]

module: CLINT

definition: This native CLINT has one clock and synchronous active-high reset. State updates only on rising clock edges. Observe combinational outputs after propagation settles. Legal active requests outside reset use opcode 0 (PutFull), 1 (PutPartial), or 4 (Get), param zero, corrupt zero, source 0..767, address[25:16]=0x200, naturally aligned size 0..3 corresponding to 1,2,4,8 bytes, and a byte mask contained within the addressed size/lanes; Get and PutFull use every addressed byte lane. A stalled A request retains valid and payload until accepted. Protocol monitor assertions remain enabled. X/Z numerical behavior is unspecified, except the comparison-register initialization rule below.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Exercise reset sampling and legal sizes, byte lanes, sources and read/write opcodes; initialize every comparison byte before numerical comparison checks.

## F2

feature_id: F2

requirement_ids: ["R-dv-026-002"]

module: CLINT

definition: auto_in_a_ready always equals auto_in_d_ready; auto_in_d_valid always equals auto_in_a_valid. No response buffer or extra cycle exists. Response source and size always copy current A source and size, including when valid is low. Response opcode is 1 precisely when current A opcode is 4 and otherwise 0. Reset does not gate these outputs. A transfer occurs when A valid and D ready are both one.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Cross A valid and D ready including stalls, and vary opcode/source/size while invalid; compare immediate coupling and metadata.

## F3

feature_id: F3

requirement_ids: ["R-dv-026-003"]

module: CLINT

definition: Decode using only address[15:0] rounded down to an eight-byte boundary. Offsets 0x0000..0x0007 read the software interrupt as a zero-extended bit; 0x4000..0x4007 read the 64-bit comparison register; 0xbff8..0xbfff read the 64-bit timer. All other offsets read zero, including the entire 0xc000..0xffff region. D data reflects this decode unconditionally, even on writes, invalid cycles and reset. It is not shifted or masked according to size or address low bits.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Read each register and neighboring unmapped locations including0xc000; vary size and low address bits legally and compare full unshifted data.

## F4

feature_id: F4

requirement_ids: ["R-dv-026-004"]

module: CLINT

definition: Reset sets the software interrupt state to zero, overriding writes. Otherwise an accepted non-Get transfer to offsets0x0000..0x0007 updates it from A data bit0 only when A mask bit0 is one. All other input data bits and mask bits have no effect on this state. auto_int_out_0 always equals this state.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Write software interrupt values0/1, exercise mask0 selected/unselected and reset/write overlap; observe both interrupt and readback.

## F5

feature_id: F5

requirement_ids: ["R-dv-026-005"]

module: CLINT

definition: Reset sets the 64-bit timer to zero and overrides writes and io_rtcTick. Otherwise an accepted non-Get transfer to offsets0xbff8..0xbfff with any asserted mask byte updates each selected byte from the same byte lane of A data, preserving unselected bytes; any such write overrides ticking for the entire timer. If no timer byte is written and io_rtcTick is one, increment by exactly one modulo 2^64. A zero-mask write does not suppress the tick. Other writes and reads do not suppress ticking.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Cross every byte mask with rtcTick, timer write/nonwrite and reset; test low/high bytes, zero mask, carry,64-bit wrap and tick suppression.

## F6

feature_id: F6

requirement_ids: ["R-dv-026-006"]

module: CLINT

definition: The 64-bit comparison register has no reset initialization. An accepted non-Get transfer to offsets0x4000..0x4007 writes selected byte lanes from A data and preserves other lanes, even while reset is high. A reset without such a write leaves its previous contents unchanged. Before initialization its unwritten bytes are unspecified; initialize every byte through legal writes before checking numerical comparison-register read data or timer interrupt. There is no other update source.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Initialize comparison in reset, alter single byte lanes, then reset again without writing and verify preservation; initialize all bytes before judging values.

## F7

feature_id: F7

requirement_ids: ["R-dv-026-007"]

module: CLINT

definition: auto_int_out_1 is the unsigned comparison timer>=comparison_register with equality included. It is combinational, independent of bus valid/ready, and not explicitly gated by reset. After initializing the comparison register, compare it against timer state including byte writes, tick transitions, equality, maximum values and wraparound.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Set timer below/equal/above threshold, maximum and zero, then tick across equality and wrap; compare timer interrupt without bus gating.

## F8

feature_id: F8

requirement_ids: ["R-dv-026-008"]

module: CLINT

definition: When A valid=0 or D ready=0, no bus write occurs, even though D valid and data remain combinationally visible. io_rtcTick may still increment the timer. All write decisions use current acceptance and opcode!=4; legal PutFull and PutPartial have the same masked state-update rules. The timer, comparison and software interrupt retain independent state; writes to unmapped addresses change none of them, while ticking remains active.

interface: ["clock", "reset", "auto_int_out_0", "auto_int_out_1", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data", "io_rtcTick"]

timing: State changes on rising clock edges; sample combinational outputs after settling.

boundary: Hold a legal write under backpressure, tick while stalled, accept later, and exercise invalid and unmapped write cycles without state changes.
