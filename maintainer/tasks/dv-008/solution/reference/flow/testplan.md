# Verification Plan

## T-1

Stimulus: Independently drive all public functional roots and separately observe each native output; CPU instructions or nonexistent CPU ports are not required. Keep the inputs of each domain independent, and jointly check the four Gray contexts and all auxiliary roots.

Expected: The task includes four Gray synchronization contexts, combinational encoding/decoding, reset synchronization, two-stage handshake buffering, debug serial output, and the remaining CDC variants; there are no CPU interface or processor instruction obligations. See the interface contract for port aliases and fixed parameters.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.

## T-2

Stimulus: The source/destination clocks of the four Gray groups are individually independent. Traverse the full two-state input space for each group, varying source-fast/destination-slow, source-slow/destination-fast, and coincident-edge phases separately; save the complete input captured on each source edge, shift it out according to each destination-edge history, and check unconverged X values and converged values cycle by cycle. For WIDTH=1, check both captured 0 and 1 after two destination edges, including coincident source/destination edges; check the additional latency only for instances with REG_OUTPUT=1.

Expected: For WIDTH=1, 2, or 4, the source-domain rising edge captures the current Gray encoding; each destination-domain rising edge advances the DEST_SYNC_FF-stage synchronization history. When REG_OUTPUT is 1, the binary decoding is output only after one additional destination rising edge. In the fixed WIDTH=1, DEST_SYNC_FF=2, REG_OUTPUT=0 context, Gray encoding and decoding both preserve the bit: each captured 0 or 1 appears after two destination rising edges. Coincident source and destination rising edges use the previous source capture. There is no reset or handshake, and the power-up history is unknown; enough effective source/destination edges must be allowed for convergence. No modeling of metastability behavior is promised.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.

## T-3

Stimulus: Exhaustively test 0 through 15 for b2g_A and g2b_A separately, and apply X and Z to each bit without changing other domains; check the corresponding conversion outputs 2ns and 8ns after driving.

Expected: With fixed N=4, binary_to_gray XORs adjacent binary bits, and gray_to_binary cumulatively XORs from the most significant bit toward the lower bits; four-state results propagate according to logical truth values.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.

## T-4

Stimulus: Drive toggling levels, consecutive identical values, and single-source-cycle pulses to both single groups, both array groups, and sync_reset; use different source/destination ratios and coincident edges, and check on every destination edge the history differences caused by the presence or absence of SRC_INPUT_REG and the 2/4-stage synchronization depths.

Expected: When SRC_INPUT_REG is 1, the input is first captured on a source rising edge; otherwise, the input is captured directly on a destination edge. DEST_SYNC_FF destination edges constitute the complete synchronization history. stolen_cdc_sync_rst is also only a destination-domain synchronization chain and does not have asynchronous reset assertion behavior.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.

## T-5

Stimulus: Assert hrstn and both polarities of src_arst separately between edges and check asynchronous responses; after deassertion, check the 2/3/4-stage release on each destination edge. Also change the sync_reset input between edges to confirm that it advances only on destination edges.

Expected: sync asynchronously clears to zero on the falling edge of rst_ni and synchronizes the input using two rising edges. stolen_cdc_async_rst asynchronously asserts the destination reset according to the fixed polarity and releases it after the specified number of destination edges; its initial value is the deasserted level. The sampling windows of the two cannot be interchanged.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.

## T-6

Stimulus: For each of the two pulse groups, drive single pulses, continuously high levels, adjacent rising events, and excessively dense events; vary source and destination speeds and check the toggle history, without assuming lossless handling of excessively dense inputs. For RST_USED=1, reset the source and destination separately; for RST_USED=0, verify that the fixed reset terminals have no effect, and observe the combinational and registered pulse windows.

Expected: A source rising edge detects src_pulse transitioning from low to high and encodes the event as a toggling level; after destination synchronization, XOR with the previous event generates a pulse, and REG_OUTPUT determines whether it is registered again. When RST_USED=0, the reset inputs have no effect. When inputs are too closely spaced, individual event delivery is not guaranteed and must be interpreted according to the actual capture history.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.

## T-7

Stimulus: For spill and flush, sequentially exercise empty, single-item and two-item filling, downstream blocking, rejection when full, concurrent input and output, draining, and reset; assert flush only when valid_i=0. Maintain a capacity-2 FIFO queue at each acceptance edge, compare data_o only when valid_o is asserted, and compare valid_o/ready_o at every point. For bypass, change valid/data/ready combinationally and check that reset does not change the transparent relationship.

Expected: Non-bypass instances have two-slot capacity; active-low asynchronous reset clears occupancy and data. ready_o is 0 only when both slots are full; valid_o indicates that at least one slot is full, and older data is output first; flush cancels occupancy and must not be accompanied by valid. In bypass instances, valid/data/ready are directly and transparently connected, and neither flush nor reset changes this relationship.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.

## T-8

Stimulus: After synchronous reset, input a nonzero new PC in mode0/1/2 respectively and hold it for sufficiently long, more than 32 cycles; check the output of 8/16/24 nibbles, low nibble first, and return to zero upon completion. Change the inputs while busy to confirm that they are not recaptured, and check the new PC after busy ends. Hold mode3 for more than 32 cycles, check that output beyond 8 nibbles is X and that the 5-bit counter wraps around; then reset to exit.

Expected: Synchronous active-high rst clears history; after detecting a PC change, capture mode/PC/instruction/writeback data and output the sequence cycle by cycle starting with the low nibble. Modes 0/1/2 serialize 8/16/24 nibbles respectively; do not recapture while busy. Mode 3 follows the PC nibble-selection path but has no mode termination condition; return values beyond the selectable range must still be checked according to the fixed RTL four-state semantics.

Checks: Independently compute expected values using only resets, inputs, and their histories; do not read DUT actual to generate expected. Inputs must be stable at least 2ns before the accepting edge; compare all valid outputs 2ns and 8ns after each event, and report UVM_ERROR on any four-state inequality. Count comparison points and prohibit zero comparisons; compare unconverged X values bit by bit according to the public contract, and compare handshake data only when valid_o is asserted.
