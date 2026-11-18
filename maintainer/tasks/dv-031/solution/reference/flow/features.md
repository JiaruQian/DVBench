### F-001
feature_id: F-001
requirement_ids: R-dv-031-001
module: BRAM_TDP_24w_256d
definition: Port A accepts the address, write enable, and data on the rising edge of its own clock. When write enable is 1, the entire word is written to the shared 256×24 memory, and douta is the value written in this operation (WRITE_FIRST); when it is 0, douta is the stored content at the address presented on that edge. There is no additional output pipeline stage or read enable.
interface: clka, rsta, wea, addra, dina, douta
timing: Data and address are stable before the edge; the output is sampled at least 1ns after the edge and holds when there is no new rising edge at that port.
boundary: Legal addresses are 0..255, including the first and last addresses, adjacent addresses, and all address bits; data uses all 24 bits, with no byte masking.

### F-002
feature_id: F-002
requirement_ids: R-dv-031-002
module: BRAM_TDP_24w_256d
definition: rsta is synchronous and active-high, setting only this port's output to 0 on a clka rising edge; it does not clear the shared memory or reset the other port. When reset and write are active simultaneously, the memory still accepts the write and the output is 0; a subsequent legal read can observe the written value.
interface: clka, rsta, wea, addra, dina, douta, rstb, doutb
timing: Changing reset between edges does not immediately clear the output; it is 0 at 1ns after the assertion edge, and normal reads and writes resume on the next edge of its own clock after deassertion.
boundary: Single-port/dual-port reset, pulses shorter than one cycle but spanning an active edge, assertion held for multiple edges, writes during reset, and cross-port readback after reset are all deterministic.

### F-003
feature_id: F-003
requirement_ids: R-dv-031-003
module: BRAM_TDP_24w_256d
definition: rsta_busy is registered state in this clock domain. After startup has stabilized, if rsta=1 at that edge, busy is set to 1; after deassertion, it remains 1 on the first and second edges of its own clock and becomes 0 on the third edge of its own clock. Reassertion extends recovery again. busy does not mask memory writes.
interface: clka, rsta, rsta_busy
timing: busy changes only on its own rising edges and is observed 1ns after the edge; stopping that clock freezes it, and the other port's clock cannot advance it.
boundary: This applies to sustained reset, single-edge reset, edges 1/2/3 after deassertion, reassertion during recovery, and unequal frequencies/stopped clocks.

### F-004
feature_id: F-004
requirement_ids: R-dv-031-004
module: BRAM_TDP_24w_256d
definition: Port B accepts the address, write enable, and data on the rising edge of its own clock. When write enable is 1, the entire word is written into the shared 256×24 memory, and doutb is simultaneously the value being written (WRITE_FIRST); when it is 0, doutb is the stored contents at the address on that edge. There is no additional output pipeline stage or read enable.
interface: clkb, rstb, web, addrb, dinb, doutb
timing: Data and address are stable before the edge; the output is sampled at least 1ns after the edge and holds when there is no new rising edge at that port.
boundary: Legal addresses are 0..255, including the first and last addresses, adjacent addresses, and all address bits; data uses all 24 bits, with no byte masking.

### F-005
feature_id: F-005
requirement_ids: R-dv-031-005
module: BRAM_TDP_24w_256d
definition: rstb is synchronous and active-high, setting only this port's output to 0 on a clkb rising edge; it does not clear the shared memory or reset the other port. When reset and write are active simultaneously, the memory still accepts the write and the output is 0; a subsequent legal read can observe the written value.
interface: clkb, rstb, web, addrb, dinb, doutb, rsta, douta
timing: Changing reset between edges does not immediately clear the output; it is 0 at 1ns after the assertion edge, and normal reads and writes resume on the next edge of its own clock after deassertion.
boundary: Single-port/dual-port reset, pulses shorter than one cycle but spanning an active edge, assertion held for multiple edges, writes during reset, and cross-port readback after reset are all deterministic.

### F-006
feature_id: F-006
requirement_ids: R-dv-031-006
module: BRAM_TDP_24w_256d
definition: rstb_busy is registered state in this clock domain. After startup has stabilized, if rstb=1 at that edge, busy is set to 1; after deassertion, it remains 1 on the first and second edges of its own clock and becomes 0 on the third edge of its own clock. Reassertion extends recovery again. busy does not mask memory writes.
interface: clkb, rstb, rstb_busy
timing: busy changes only on its own rising edges and is observed 1ns after the edge; stopping that clock freezes it, and the other port's clock cannot advance it.
boundary: This applies to sustained reset, single-edge reset, edges 1/2/3 after deassertion, reassertion during recovery, and unequal frequencies/stopped clocks.

### F-007
feature_id: F-007
requirement_ids: R-dv-031-007
module: BRAM_TDP_24w_256d
definition: The two ports share the same memory; after A writes, B can observe that value by reading the same address on a later non-colliding edge, and vice versa. Operations on different addresses by the two ports do not affect each other; stopping one port's clock does not affect the other port.
interface: clka, clkb, wea, web, addra, addrb, dina, dinb, douta, doutb
timing: The two ports may have different periods and different phases; a subsequent read edge must be at least 2ns after the preceding write edge.
boundary: Cross-port operations less than 2ns apart, at the same address, and with at least one port writing are excluded; simultaneous reads of the same address by both ports are legal. No conflict arbitration or memory result after a collision is specified.

### F-008
feature_id: F-008
requirement_ids: R-dv-031-008
module: BRAM_TDP_24w_256d
definition: The maintained simulation environment provides a 100ns global startup reset. Both clocks remain stationary at low level and start only after 110ns. All 256 words of memory are initially 0. The first 12 rising edges of each port are used for startup settling; thereafter, evaluation follows the normal read/write, reset, and busy contracts.
interface: clka, clkb, rsta, rstb, rsta_busy, rstb_busy, douta, doutb, addra, addrb
timing: Write enables must be 0 during startup settling; after the 12 edge, initial values can be read and busy is 0 without an additional user reset.
boundary: The startup domain does not specify the exact output/busy waveforms for the first 12 edges; this exemption must not be applied to subsequent user resets.
