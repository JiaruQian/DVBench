# cdc_source_bundle Behavioral Specification

Specification revision: dv-008-gray-cdc-v3.2-20261118. Requirement identifiers are retained as stable traceability anchors.

### R-dv-008-source-v3.1-C001 — Actual Source Scope

The task includes four Gray synchronization contexts, combinational encoding/decoding, reset synchronization, two-stage handshake buffering, debug serial output, and the remaining CDC variants; there are no CPU interface or processor instruction obligations. See the interface contract for port aliases and fixed parameters.

### R-dv-008-source-v3.1-C002 — Gray History

For WIDTH=1, 2, or 4, the source-domain rising edge captures the current Gray encoding; each destination-domain rising edge advances the DEST_SYNC_FF-stage synchronization history. When REG_OUTPUT is 1, the binary decoding is output only after one additional destination rising edge. In the fixed WIDTH=1, DEST_SYNC_FF=2, REG_OUTPUT=0 context, Gray encoding and decoding both preserve the bit: each captured 0 or 1 appears after two destination rising edges. Coincident source and destination rising edges use the previous source capture. There is no reset or handshake, and the power-up history is unknown; enough effective source/destination edges must be allowed for convergence. No modeling of metastability behavior is promised.

### R-dv-008-source-v3.1-C003 — Combinational Conversion

With fixed N=4, binary_to_gray XORs adjacent binary bits, and gray_to_binary cumulatively XORs from the most significant bit toward the lower bits; four-state results propagate according to logical truth values.

### R-dv-008-source-v3.1-C004 — Level and Array Synchronization

When SRC_INPUT_REG is 1, the input is first captured on a source rising edge; otherwise, the input is captured directly on a destination edge. DEST_SYNC_FF destination edges constitute the complete synchronization history. stolen_cdc_sync_rst is also only a destination-domain synchronization chain and does not have asynchronous reset assertion behavior.

### R-dv-008-source-v3.1-C005 — Synchronous and Asynchronous Reset

sync asynchronously clears to zero on the falling edge of rst_ni and synchronizes the input using two rising edges. stolen_cdc_async_rst asynchronously asserts the destination reset according to the fixed polarity and releases it after the specified number of destination edges; its initial value is the deasserted level. The sampling windows of the two cannot be interchanged.

### R-dv-008-source-v3.1-C006 — Pulse Synchronization

A source rising edge detects src_pulse transitioning from low to high and encodes the event as a toggling level; after destination synchronization, XOR with the previous event generates a pulse, and REG_OUTPUT determines whether it is registered again. When RST_USED=0, the reset inputs have no effect. When inputs are too closely spaced, individual event delivery is not guaranteed and must be interpreted according to the actual capture history.

### R-dv-008-source-v3.1-C007 — Handshake Buffering

Non-bypass instances have a two-slot capacity, and active-low asynchronous reset clears occupancy and data. ready_o is 0 only when both slots are full; valid_o indicates that at least one slot is full, and older data is output first; flush cancels occupancy and must not be asserted simultaneously with valid. The valid/data/ready signals of the bypass instance are directly and transparently connected, and neither flush nor reset changes this relationship.

### R-dv-008-source-v3.1-C008 — Debug Serial Output

Synchronous active-high rst clears the history; after detecting a PC change, mode/PC/instruction/writeback data are captured, and a sequence starting with the low nibble is output cycle by cycle. Modes 0/1/2 serialize 8/16/24 nibbles, respectively; no recapture occurs while busy. Mode 3 follows the PC nibble-selection path but has no mode termination condition; return values beyond the selectable range must still be checked according to the fixed RTL four-state semantics.


## Valid Inputs and Observation Windows

All clocks are independent. Inputs are stable at least 2ns before their accepting edges, and observations occur 2ns and 8ns after events; simultaneous rising edges of different clocks are allowed, in which case all registered histories use pre-edge values. Except for the independent combinational encoding/decoding roots, where per-bit X/Z is allowed, sequential stimulus is two-state; uninitialized power-up outputs remain four-state unknowns and must converge after sufficient history. Each synchronization history, combinational auxiliary domain, and reset domain is independent. Handshake data_o has a validity obligation only when valid_o=1; no commitment is made regarding residual stored data when valid_o=0. flush_i and valid_i must not both be 1. The debug mode3 counter is 5 bits; after passing the 8 nibbles of the PC, the output is X, and the count wraps modulo 32; mode3 itself has no termination condition, but reset can terminate it.
