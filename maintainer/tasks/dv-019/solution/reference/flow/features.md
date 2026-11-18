# Feature List

## F-1

The interface includes an independent UART, PS/2 keyboard reception, and ASCII conversion of the keyboard queue head. The two receivers share clk/rst_n; the keyboard queue head connects to the conversion input, while the UART transmit input remains externally driven, with no implicit automatic forwarding between them.

The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-2

ps2c is filtered using an 8-bit history sampled by clk; only filtered falling edges advance the 11-bit frame. The 8 data bits are extracted by right shifting, without validating the start, parity, or stop bits; there is no timeout, and an incomplete frame can continue waiting.

The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-3

After f0, the next completed byte is swallowed; 12 or 59 sets a single shift state, and releasing either shift clears it. Other completed bytes form queue write requests of {old shift,scan code}; e0/e1 receive no special parsing.

The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-4

The keyboard queue has depth 4 and width 9; the two UART queues have depth 4 and width 8. A nonempty head is a combinational output. A read alone advances when nonempty, and a write alone advances when not full; simultaneous read and write advance only when neither empty nor full, with no empty bypass or full replacement. Reset clears only logical occupancy and does not erase storage.

The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-5

Parameters are fixed at DBIT=8, SB_TICK=16, DVSR=4, DVSR_WIDTH=2, FIFO_W=2. A low level triggers start detection; the data phase begins after 8 visible ticks, after which one data bit is sampled every 16 ticks, LSB first, and completion occurs after 16 ticks in the stop phase. There is no stop-high detection or error port.

The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-6

A nonempty transmit FIFO triggers latching of the queue head; registered tx is 0 during reset and idle high after reset release. The start bit, 8 LSB-first data bits, and stop bit each advance according to 16 visible ticks, and the queue head is released only when transmission completes. There are no re-latching semantics during transmission.

The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.

## F-7

rd_data[8:0] is the complete lookup key, and ascii[7:0] is the combinational result for the current key. There is no clock, reset, handshake, state, or fixed cycle latency; observe after the input is stable and combinational propagation has occurred. Consecutive inputs are independent of previous keys.



The low 8-bit scan codes 1c 32 21 23 24 2b 34 33 43 3b 42 4b 3a 31 44 4d 15 2d 1b 2c 3c 2a 1d 22 35 1a represent a through z, respectively, in that order; bit8=0 outputs ASCII 61 through 7a, and bit8=1 outputs 41 through 5a. All values are hexadecimal.



When bit8=0, scan codes 45 16 1e 26 25 2e 36 3d 3e 46 output 30 through 39 in order; scan codes 0e 4e 55 54 5b 5d 4c 52 41 49 4a 29 5a 66 output 60 2d 3d 5b 5d 5c 3b 27 2c 2e 2f 20 0d 08 in order. bit8=1 defines no alternate characters for these special characters; the unmatched rule applies. All values are hexadecimal.



Any input that does not exactly match one of the complete 9-bit keys above outputs 2a, including keys containing X or Z; it neither retains the previous output nor outputs zero as the default.

The clk period is 20ns; drive on falling edges and accept on the next rising edge; observe at 2ns and 8ns after the edge. The 16 acceptance edges after the last raw keyboard stop-bit falling edge constitute the filtering/write transition, after which every frame must be checked; an empty head has no data obligation, and a nonempty head must be checked.

Bounded by this item's conditions and the interface contract's valid input domain and observation windows.
