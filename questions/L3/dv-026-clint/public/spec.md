# CLINT behavioral specification

The full native timer/software-interrupt endpoint and its protocol monitor are in scope.

### R-dv-026-001 — Native timing and legal TileLink domain

This native CLINT has one clock and synchronous active-high reset. State updates only on rising clock edges. Observe combinational outputs after propagation settles. Legal active requests outside reset use opcode 0 (PutFull), 1 (PutPartial), or 4 (Get), param zero, corrupt zero, source 0..767, address[25:16]=0x200, naturally aligned size 0..3 corresponding to 1,2,4,8 bytes, and a byte mask contained within the addressed size/lanes; Get and PutFull use every addressed byte lane. A stalled A request retains valid and payload until accepted. Protocol monitor assertions remain enabled. X/Z numerical behavior is unspecified, except the comparison-register initialization rule below.

### R-dv-026-002 — Combinational request/response coupling

auto_in_a_ready always equals auto_in_d_ready; auto_in_d_valid always equals auto_in_a_valid. No response buffer or extra cycle exists. Response source and size always copy current A source and size, including when valid is low. Response opcode is 1 precisely when current A opcode is 4 and otherwise 0. Reset does not gate these outputs. A transfer occurs when A valid and D ready are both one.

### R-dv-026-003 — Register decoding and read data

Decode using only address[15:0] rounded down to an eight-byte boundary. Offsets 0x0000..0x0007 read the software interrupt as a zero-extended bit; 0x4000..0x4007 read the 64-bit comparison register; 0xbff8..0xbfff read the 64-bit timer. All other offsets read zero, including the entire 0xc000..0xffff region. D data reflects this decode unconditionally, even on writes, invalid cycles and reset. It is not shifted or masked according to size or address low bits.

### R-dv-026-004 — Software interrupt state

Reset sets the software interrupt state to zero, overriding writes. Otherwise an accepted non-Get transfer to offsets0x0000..0x0007 updates it from A data bit0 only when A mask bit0 is one. All other input data bits and mask bits have no effect on this state. auto_int_out_0 always equals this state.

### R-dv-026-005 — Timer state, masked writes and tick priority

Reset sets the 64-bit timer to zero and overrides writes and io_rtcTick. Otherwise an accepted non-Get transfer to offsets0xbff8..0xbfff with any asserted mask byte updates each selected byte from the same byte lane of A data, preserving unselected bytes; any such write overrides ticking for the entire timer. If no timer byte is written and io_rtcTick is one, increment by exactly one modulo 2^64. A zero-mask write does not suppress the tick. Other writes and reads do not suppress ticking.

### R-dv-026-006 — Comparison register without reset

The 64-bit comparison register has no reset initialization. An accepted non-Get transfer to offsets0x4000..0x4007 writes selected byte lanes from A data and preserves other lanes, even while reset is high. A reset without such a write leaves its previous contents unchanged. Before initialization its unwritten bytes are unspecified; initialize every byte through legal writes before checking numerical comparison-register read data or timer interrupt. There is no other update source.

### R-dv-026-007 — Timer interrupt comparison

auto_int_out_1 is the unsigned comparison timer>=comparison_register with equality included. It is combinational, independent of bus valid/ready, and not explicitly gated by reset. After initializing the comparison register, compare it against timer state including byte writes, tick transitions, equality, maximum values and wraparound.

### R-dv-026-008 — Backpressure and independent updates

When A valid=0 or D ready=0, no bus write occurs, even though D valid and data remain combinationally visible. io_rtcTick may still increment the timer. All write decisions use current acceptance and opcode!=4; legal PutFull and PutPartial have the same masked state-update rules. The timer, comparison and software interrupt retain independent state; writes to unmapped addresses change none of them, while ticking remains active.
