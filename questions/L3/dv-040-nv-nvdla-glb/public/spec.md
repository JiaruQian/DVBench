# Global interrupt controller

Verify the complete native module using both independently driven clocks. Requests use word addresses and fixed-width payloads.

### R-p8-glb-001 — Clock and reset domains

The core and falcon clocks are independent. nvdla_core_rstn asynchronously clears the core request pipeline, response valid/data, interrupt masks, pending event status, sampled event inputs and the core-domain interrupt launch value. nvdla_falcon_rstn independently asynchronously clears the three-stage falcon interrupt history and core_intr. Each reset is active low and may interrupt traffic. Release away from the relevant rising edge. A core reset alone does not directly clear the falcon history; its zero interrupt launch propagates on subsequent falcon edges. A falcon reset does not change core register state. csb2glb_req_prdy is always one, including reset.

### R-p8-glb-002 — CSB request and response pipeline

Every core rising edge with csb2glb_req_pvld high accepts the 63-bit request because request-ready is constantly high. Request bits21:0 are a word address, bits53:22 are write data, bit54 selects write when one, and bit55 requests a write acknowledgement when one. Bits62:56 are ignored. Requests are processed on the following core rising edge, using state from just before that processing edge. Reads produce a valid response then. Nonposted writes produce a valid response with bit33 one and bits32:0 zero; posted writes produce no response. Read response bit33 and error bit32 are zero, and bits31:0 contain the register value. Back-to-back requests are supported with one processed per edge. Response payload is reset to zero and otherwise retains its previous value when no response is produced.

### R-p8-glb-003 — Register decode and readback

Only the low ten word-address bits are decoded; higher request-address bits alias. Word offsets zero, one, two and three select version, interrupt mask, software set and interrupt status. Other decoded offsets read as zero and writes have no effect. Version reads 0x00303031 and ignores writes. The set register always reads zero. The mask register implements bits9:0 and21:16, reads all other bits as zero, resets to zero and replaces all implemented bits on a processed mask write. Its bits7:6 and9:8 are writable/readable mask storage for absent engines and cannot themselves produce an interrupt. Register reads sample the old state at the processing edge before concurrent state updates.

### R-p8-glb-004 — External and software event accumulation

The six two-bit completion inputs correspond respectively to status bits1:0 for SDP,3:2 for CDP,5:4 for PDP,17:16 for CDMA data,19:18 for CDMA weights and21:20 for CACC. Each input is sampled on a core rising edge and the sampled event sets its sticky status on the following core rising edge. Both bits of a completion input are legal binary events. A processed write to software set offset two sets the corresponding implemented status bits immediately after that processing edge. Implemented sticky status bits are0x003f003f; all other status bits read zero. Status persists after an event input returns to zero. Reading the set register does not reveal or clear pending events.

### R-p8-glb-005 — Write-one clear and set priority

A processed write to status offset three clears exactly those implemented pending bits whose write-data bits are one. Zero write bits preserve status. Software set or the previously sampled external event takes priority over a simultaneous clear for the same bit. A still-asserted external event therefore keeps or reasserts its pending status. Writes to reserved status/set bits have no effect.

### R-p8-glb-006 — Interrupt masking and synchronization

After every core edge, the launch value for the falcon domain is the OR of the pre-edge implemented pending status bits that have their corresponding mask bits zero. Mask one suppresses that source only; setting a mask does not clear status, and unmasking a pending source restores the launch. The launch value passes through exactly three falcon rising-edge history stages before appearing at core_intr. The falcon output samples the launch value that existed before its edge, including when core and falcon edges coincide. Multiple active sources OR together. There is no combinational mask-to-core_intr bypass.

### R-p8-glb-007 — Neutral inputs and legal domain

direct_reset_ and test_mode do not affect the functional outputs in this supplied configuration. Drive known binary inputs stable around rising core edges, and release domain resets away from their rising edges. All native payload values and ignored field patterns are legal; behavior under X/Z controls or setup/hold violations is outside the contract. The deterministic supplied three-stage synchronization library configuration is selected for this task; random metastability-delay injection is not part of the functional contract. There are no configurable parameters.
