# Verification Plan

## T-1

Stimulus: Drive the UART RX/TX and PS/2 inputs separately; run them independently and concurrently, confirming that the keyboard head feeds only ASCII and is not automatically forwarded to the UART. Reset and check the public outputs of the three functional roots.

Expected: The interface includes an independent UART, PS/2 keyboard reception, and ASCII conversion of the keyboard queue head. The two receivers share clk/rst_n; the keyboard queue head connects to the conversion input, while the UART transmit input remains externally driven, with no implicit automatic forwarding between them.

Check: Build UART transaction counts, PS/2 filtering and frame history, three capacity-4 queues, and character mapping based only on reset, inputs, and their history; do not read DUT actual to generate expected. The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked. Compare all valid outputs using four-state comparison, with any mismatch producing UVM_ERROR; count comparison points and prohibit zero comparisons.

## T-2

Stimulus: Generate 11-bit PS/2 frames, holding each clock level for at least 12 clk cycles; data within frames is LSB first. Iterate through all 256 bytes and vary the start/parity/stop bits to confirm there is no error filtering; pause within a frame and then resume to confirm there is no timeout. Wait 16 clk rising edges after the last raw stop-bit falling edge, then check the valid queue head.

Expected: ps2c is filtered using an 8-bit history sampled by clk; only filtered falling edges advance the 11-bit frame. The 8 data bits are extracted by right shifting, without validating the start, parity, or stop bits; there is no timeout, and an incomplete frame can continue waiting.

Check: Build UART transaction counts, PS/2 filtering and frame history, three capacity-4 queues, and character mapping based only on reset, inputs, and their history; do not read DUT actual to generate expected. The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked. Compare all valid outputs using four-state comparison, with any mismatch producing UVM_ERROR; count comparison points and prohibit zero comparisons.

## T-3

Stimulus: Send ordinary codes, 12, 59, f0 and its following byte, e0, and e1 in sequence; check 9bit enqueueing using the old shift state, and clearing after either shift is released; predict consecutive breaks, dual shifts, and ordinary codes after break using the input-history queue. Compare after each frame stabilizes; valid characters must not be skipped.

Expected: After f0, the next completed byte is swallowed; 12 or 59 sets a single shift state, and releasing either shift clears it. Other completed bytes form queue write requests of {old shift,scan code}; e0/e1 receive no special parsing.

Check: Build UART transaction counts, PS/2 filtering and frame history, three capacity-4 queues, and character mapping based only on reset, inputs, and their history; do not read DUT actual to generate expected. The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked. Compare all valid outputs using four-state comparison, with any mismatch producing UVM_ERROR; count comparison points and prohibit zero comparisons.

## T-4

Stimulus: For each of the three depth-4 queues, exercise empty, filling to one item, half full, full, and reading until empty; drive simultaneous reads and writes at empty/full/intermediate occupancy and check rejection or advancement of both. Keep keyboard operations away from the frame-completion transition; complete a frame with the queue full to check rejection; reset while the queue is nonempty to confirm occupancy clears. An empty head has no obligation; a nonempty head must be compared.

Expected: The keyboard queue has depth 4 and width 9; the two UART queues have depth 4 and width 8. A nonempty head is a combinational output. A read alone advances when nonempty, and a write alone advances when not full; simultaneous read and write advance only when neither empty nor full, with no empty bypass or full replacement. Reset clears only logical occupancy and does not erase storage.

Check: Build UART transaction counts, PS/2 filtering and frame history, three capacity-4 queues, and character mapping based only on reset, inputs, and their history; do not read DUT actual to generate expected. The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked. Compare all valid outputs using four-state comparison, with any mismatch producing UVM_ERROR; count comparison points and prohibit zero comparisons.

## T-5

Stimulus: Release reset to establish the 4-cycle tick history, and send all 256 bytes using a low start for 8 ticks, 8 data bits of 16 ticks each, and a stop for 16 ticks; check receive FIFO values and occupancy. Vary the stop level, exercise consecutive frames, rejection when the FIFO is full, reset during reception, and simultaneous read/write boundaries; change inputs on falling edges and consume the preceding tick on a subsequent acceptance edge.

Expected: Parameters are fixed at DBIT=8, SB_TICK=16, DVSR=4, DVSR_WIDTH=2, FIFO_W=2. A low level triggers start detection; the data phase begins after 8 visible ticks, after which one data bit is sampled every 16 ticks, LSB first, and completion occurs after 16 ticks in the stop phase. There is no stop-high detection or error port.

Check: Build UART transaction counts, PS/2 filtering and frame history, three capacity-4 queues, and character mapping based only on reset, inputs, and their history; do not read DUT actual to generate expected. The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked. Compare all valid outputs using four-state comparison, with any mismatch producing UVM_ERROR; count comparison points and prohibit zero comparisons.

## T-6

Stimulus: Write all 256 bytes to the TX FIFO in sequence, independently predicting the start/each LSB-first data bit/stop according to registered TX and dequeueing after completion; check reset TX=0, idle after release=1, back-to-back transmission, rejection when full, enqueueing during transmission without changing the current character, and reset during transmission.

Expected: A nonempty transmit FIFO triggers latching of the queue head; registered tx is 0 during reset and idle high after reset release. The start bit, 8 LSB-first data bits, and stop bit each advance according to 16 visible ticks, and the queue head is released only when transmission completes. There are no re-latching semantics during transmission.

Check: Build UART transaction counts, PS/2 filtering and frame history, three capacity-4 queues, and character mapping based only on reset, inputs, and their history; do not read DUT actual to generate expected. The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked. Compare all valid outputs using four-state comparison, with any mismatch producing UVM_ERROR; count comparison points and prohibit zero comparisons.

## T-7

Stimulus: Through PS/2, construct unshifted and shifted letters, digits, symbols, special keys, and unmatched 9bit keys in sequence; independently compare ASCII using the specified mapping when the queue head is valid. Use consecutive different keys to check the absence of history; exhaustive testing of 512 keys in the independent character-conversion subtask serves as additional evidence. Check the X/Z default only when the independent conversion input can be driven directly; do not claim it is reachable from two-state PS/2.

Expected: rd_data[8:0] is the complete lookup key, and ascii[7:0] is the combinational result for the current key. There is no clock, reset, handshake, state, or fixed cycle latency; observe after the input is stable and combinational propagation has occurred. Consecutive inputs are independent of previous keys.



The low 8-bit scan codes 1c 32 21 23 24 2b 34 33 43 3b 42 4b 3a 31 44 4d 15 2d 1b 2c 3c 2a 1d 22 35 1a represent a through z, respectively, in that order; bit8=0 outputs ASCII 61 through 7a, and bit8=1 outputs 41 through 5a. All values are hexadecimal.



When bit8=0, scan codes 45 16 1e 26 25 2e 36 3d 3e 46 output 30 through 39 in order; scan codes 0e 4e 55 54 5b 5d 4c 52 41 49 4a 29 5a 66 output 60 2d 3d 5b 5d 5c 3b 27 2c 2e 2f 20 0d 08 in order. bit8=1 defines no alternate characters for these special characters; the unmatched rule applies. All values are hexadecimal.



Any input that does not exactly match one of the complete 9-bit keys above outputs 2a, including keys containing X or Z; it neither retains the previous output nor outputs zero as the default.

Check: Build UART transaction counts, PS/2 filtering and frame history, three capacity-4 queues, and character mapping based only on reset, inputs, and their history; do not read DUT actual to generate expected. The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked. Compare all valid outputs using four-state comparison, with any mismatch producing UVM_ERROR; count comparison points and prohibit zero comparisons.
