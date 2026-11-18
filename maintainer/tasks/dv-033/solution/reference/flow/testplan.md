# tests

test_id: T1

feature_ids: ['F1']

requirement_ids: ['R-dv-033-001']

stimulus: Start with SS high for 400ns; in each transaction, transmit the command MSB first with a 50ns half-period and 0/1/4/255/256/1023/1030 payload bytes, interrupt across SS and restart.

expected: Fixed STRLEN=0, PS2DIV=100, ROM_DIRECT_UPLOAD=0. SS high resets the SPI bit counter and 10-bit byte counter, MISO is Z, and the response is preloaded with A4; falling edges shift out bits MSB first, rising edges sample MOSI, and the 8th bit assembles a byte. The SPI byte count saturates at 1023, and conf_addr is this count. The byte-completion toggle passes through two-stage synchronization in sys/sd and is processed when the two synchronization bits differ; the local byte counts in the two domains each saturate at 255 and clear to 0 after SS termination is synchronized. Inputs are held between bits, and completed bytes must span enough sys/sd edges to avoid losing toggle events; this contract requires an SPI half-period of at least 50ns, a sys period of 10ns, an sd period of 14ns, and SS high for at least 400ns. There is no global reset port.

checker: Independently decode SPI bytes and use event histories in both domains to predict counts, MISO, and the configuration address; sample MISO after it settles following falling edges, and check four-state outputs after rising edges and domain edges.

implementation_id: V1

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T2

feature_ids: ['F2']

requirement_ids: ['R-dv-033-002']

stimulus: Vary conf_chr and sd drive0/1 read/write combinations, change LBA/drive after command 16 to verify the snapshot, go beyond the end of the response, and send unknown commands.

expected: Each byte ending for command 14 samples conf_chr as the next response; STRLEN=0 uses the external RAM input. Responses after command 16 are, in order, {6,sd_conf,sd_sdhc,sd_wr[drive],sd_rd[drive]}, the 8-bit value of drive, the four LBA bytes from highest to lowest, then 0. drive=sd_rd[1]|sd_wr[1]; LBA/drive are latched at the end of the command byte, and subsequent changes do not affect this transaction's snapshot. The next response for command 18 is sd_din at that time. Subsequent responses for undefined commands are 0.

checker: Predict MISO bit by bit using independent command decoding and input snapshots, without using actual returned bytes as the oracle.

implementation_id: V2

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T3

feature_ids: ['F3']

requirement_ids: ['R-dv-033-003']

stimulus: Send 1, 2, 4, and 6 bytes to each of the five joystick groups, alternating all-0/all-1 and seed-mixed bytes; cover all 7 button bits and overwrites by multiple payloads.

expected: Each payload of command 01 overwrites the control word: bits 1:0 are buttons, 3:2 are switches, 4 is scan-doubler disable, 5 is ypbpr, and 6 is no_csync; bit 7 is ignored. 60–64 update the five 32-bit joysticks respectively; the first four payloads write bits 7:0/15:8/23:16/31:24 in order, and other payloads are ignored. Partial transactions change only the bytes sent; uninitialized portions are X, and initialized but unwritten portions retain their values.

checker: Update byte by byte according to independent register history and compare the relevant outputs in four states after domain-synchronized processing; do not arbitrarily clear unwritten portions to zero.

implementation_id: V3

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T4

feature_ids: ['F4']

requirement_ids: ['R-dv-033-004']

stimulus: Send index0–15 individually, separate X/Y and truncate transactions, and append extra payloads.

expected: Only the low 3 bits of the first payload of command 1A form index; index0/1 are valid. The second payload updates the high byte X, the third updates the low byte Y, and the rest are ignored. index2–7 do not update any analog joystick; for example, the low 3 bits of 8 are 0. Partial updates preserve the other byte.

checker: Independently calculate using only the low 3 bits of the input index and the byte position, and separately check retention and updates of the two 16-bit channels.

implementation_id: V4

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T5

feature_ids: ['F5']

requirement_ids: ['R-dv-033-005']

stimulus: First establish definite values byte by byte, then mix 15/1E partial overwrites, core bit7, non-BCD RTC data, and overlong payloads; set status0 to 1 and then clear it to 0.

expected: Each payload of 15 overwrites the entire 32-bit status with the zero-extended 8-bit value; the first four payloads of 1E update the 32-bit status byte by byte in little-endian order, and the rest are ignored. Each payload of 21 writes the low 7 bits to core_mod. The first eight payloads of 22 update the 64-bit rtc byte by byte in little-endian order, without validating BCD or the date; extras are ignored. There are no relevant power-up initial values, and portions retain their values after writes. A rise of status[0] flushes both serial read and write pointers simultaneously; remaining at 1 prohibits serial writes.

checker: Predict using independent byte write masks and zero extension, and compare all registers and read behavior after the serial flush.

implementation_id: V5

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T6

feature_ids: ['F6']

requirement_ids: ['R-dv-033-006']

stimulus: Ordinary initial codes, E0/F0 combinations, repeated prefixes, multiple ordinary codes in the same frame, an ordinary code starting a new frame after E0 in the preceding frame, and truncated prefixes.

expected: Each payload of 05 enters keyboard processing; at the start of the first payload, pressed defaults to 1 and extended defaults to 0. E0 sets extended, and F0 clears pressed; an ordinary code emits key_code, with key_extended=historical extended AND not the first payload, and key_pressed=historical pressed OR the first payload. A prefix itself does not emit key_strobe; an ordinary code emits it for one cycle on the processing sys edge, and it clears on the next sys edge. The first ordinary code of a new transaction is always a non-extended make and does not inherit an old prefix.

checker: An independent input prefix state machine predicts codes and flags; check the single-cycle strobe and event values on every sys edge. Reading only the final key_code is prohibited.

implementation_id: V6

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T7

feature_ids: ['F7']

requirement_ids: ['R-dv-033-007']

stimulus: All flags sign combinations for 70/71, X/Y boundaries, ignoring the upper 4 bits of Z, and 3/4/5-byte lengths.

expected: The first four payloads of 70/71 are flags, X, Y, and Z respectively. Publish once when the fourth byte is processed: X is {flags[4],Xbyte}, Y is {flags[5],Ybyte}, Z is the low 4 bits of the payload, idx=the low bit of the command, and flags are retained in full. strobe is high for one cycle on that sys edge. Fewer than four bytes do not publish, and extra bytes do not publish again.

checker: Independently buffer input packets; publish and compare only on the fourth byte, and check for no extra strobes and for value retention on other sys edges.

implementation_id: V7

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T8

feature_ids: ['F8']

requirement_ids: ['R-dv-033-008']

stimulus: Send 0, 1, multiple bytes, and more than 512 bytes for each of 17/19, and observe synchronized clearing on SS deassertion; alternate commands and interrupt transactions.

expected: Commands 17/18 assert sd_ack when received in the sd domain; 19 asserts sd_ack_conf. Each payload of 17/19 generates a single-cycle sd_dout_strobe and outputs that byte; the next sd edge clears strobe and increments the 9-bit address by 1. The address saturates at 511 rather than wrapping around. After SS termination is synchronized, ack and both strobes are cleared and the address is cleared to 0; sd_dout retains its last value.

checker: An independent byte-event queue predicts ack/strobe on each sd edge and address ordering, covering saturation at 511 and data retention.

implementation_id: V8

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T9

feature_ids: ['F9']

requirement_ids: ['R-dv-033-009']

stimulus: Upload more than 512 bytes, vary sd_din with input history, and change the two sd_wr bits separately; combine these with SS termination and byte processing on the same edge.

expected: The 18 command and subsequent payloads request the next sd_din: command processing first strobes and increments address 0 by 1; afterward, it strobes again and increments by 1 only when address!=511. The MISO response samples sd_din at the end of the SPI byte, independently of the sd-domain strobe. A rising edge of sd_wr[0] triggers address 0 and din_strobe in the sd domain; a rising edge of sd_wr[1] alone does not trigger this prefetch. SS termination takes priority in clearing the address and strobe.

checker: Independently simulate SD request edges and last-assignment priority; compare data-line responses and request strobes separately, without incorrectly assigning them the same latency.

implementation_id: V9

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T10

feature_ids: ['F10']

requirement_ids: ['R-dv-033-010']

stimulus: Two drives, irrelevant upper payload bits, partial size, four-byte boundaries and extra bytes, and alternating size writes before and after mounting.

expected: Each payload of 1C selects img_mounted[0/1] by its least significant bit and sets it to 1; it clears by default on the next sd edge, and the two bits can each pulse on consecutive events. The first four payloads of 1D write the 32-bit img_size in little-endian order; partial transactions preserve other bytes, and further bytes are ignored. Mounting does not automatically clear size.

checker: Independently predict single-cycle mounting and byte write masks from input commands, and perform four-state checks within the sd-domain synchronization window.

implementation_id: V10

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T11

feature_ids: ['F11']

requirement_ids: ['R-dv-033-011']

stimulus: After reset by status, write 0/1/63/64/65 bytes, alternate flag/data reads, read beyond empty, write during reads, and flush again with status.

expected: A rise of serial_strobe writes serial_data into a 64-entry ring; the write pointer is modulo 64, with no full detection. Equal read and write pointers indicate empty, so writing a full 64 entries appears empty. A rise of status[0] clears both pointers. 1B responses alternate according to byte-count parity: the first response after the command is the current read byte, followed by {1000000,available}, then continuing to alternate data/flag. The read pointer advances only on the SPI falling edge at the end of a nonzero even-numbered byte and only if data is available. The data storage itself is not guaranteed to be 0 when empty.

checker: Predict responses using an independent 64-entry ring and read/write pointer history; preserve four-state storage semantics for empty data, and do not treat the flag as another FIFO depth.

implementation_id: V11

source: native_pkg.sv:native_sequence.body/native_scoreboard.write

test_id: T12

feature_ids: ['F12']

requirement_ids: ['R-dv-033-012']

stimulus: Use native power-up without force, run the sys clock and send keyboard/mouse data, while also checking structured events.

expected: The fixed RTL has no reset or initial values for the PS2 divider count, clock, transmit state, or FIFO pointers; these states remain unknown at native four-state startup, and valid serial frames cannot be guaranteed on the four PS2 outputs. Do not force the internal clock or add a reset for it. The keyboard/mouse structured event ports remain testable under the command contract above; PS2 unknowns must not be generalized to mean that other outputs need not be checked.

checker: Record evidence of PS2 four-state unknowns and fully compare the defined structured ports; do not use PS2 serial transmission failures as a criterion for reachable mutant eligibility.

implementation_id: V12

source: native_pkg.sv:native_sequence.body/native_scoreboard.write
