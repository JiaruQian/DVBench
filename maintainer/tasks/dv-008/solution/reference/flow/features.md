# Feature List

## F-1

The task includes four Gray synchronization contexts, combinational encoding/decoding, reset synchronization, two-stage handshake buffering, debug serial output, and the remaining CDC variants; there are no CPU interface or processor instruction obligations. See the interface contract for port aliases and fixed parameters.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-2

For WIDTH=1, 2, or 4, the source-domain rising edge captures the current Gray encoding; each destination-domain rising edge advances the DEST_SYNC_FF-stage synchronization history. When REG_OUTPUT is 1, the binary decoding is output only after one additional destination rising edge. In the fixed WIDTH=1, DEST_SYNC_FF=2, REG_OUTPUT=0 context, Gray encoding and decoding both preserve the bit: each captured 0 or 1 appears after two destination rising edges. Coincident source and destination rising edges use the previous source capture. There is no reset or handshake, and the power-up history is unknown; enough effective source/destination edges must be allowed for convergence. No modeling of metastability behavior is promised.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-3

With fixed N=4, binary_to_gray XORs adjacent binary bits, and gray_to_binary cumulatively XORs from the most significant bit toward the lower bits; four-state results propagate according to logical truth values.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-4

When SRC_INPUT_REG is 1, the input is first captured on a source rising edge; otherwise, the input is captured directly on a destination edge. DEST_SYNC_FF destination edges constitute the complete synchronization history. stolen_cdc_sync_rst is also only a destination-domain synchronization chain and does not have asynchronous reset assertion behavior.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-5

sync asynchronously clears to zero on the falling edge of rst_ni and synchronizes the input using two rising edges. stolen_cdc_async_rst asynchronously asserts the destination reset according to the fixed polarity and releases it after the specified number of destination edges; its initial value is the deasserted level. The sampling windows of the two cannot be interchanged.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-6

A source rising edge detects src_pulse transitioning from low to high and encodes the event as a toggling level; after destination synchronization, XOR with the previous event generates a pulse, and REG_OUTPUT determines whether it is registered again. When RST_USED=0, the reset inputs have no effect. When inputs are too closely spaced, individual event delivery is not guaranteed and must be interpreted according to the actual capture history.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-7

Non-bypass instances have a two-slot capacity, and active-low asynchronous reset clears occupancy and data. ready_o is 0 only when both slots are full; valid_o indicates that at least one slot is full, and older data is output first; flush cancels occupancy and must not be asserted simultaneously with valid. The valid/data/ready signals of the bypass instance are directly and transparently connected, and neither flush nor reset changes this relationship.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-8

Synchronous active-high rst clears the history; after detecting a PC change, mode/PC/instruction/writeback data are captured, and a sequence starting with the low nibble is output cycle by cycle. Modes 0/1/2 serialize 8/16/24 nibbles, respectively; no recapture occurs while busy. Mode 3 follows the PC nibble-selection path but has no mode termination condition; return values beyond the selectable range must still be checked according to the fixed RTL four-state semantics.

Stable before the accepting edge of each native clock, with observations 2ns and 8ns after the edge; combinational inputs likewise use 2ns and 8ns settling windows.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.
