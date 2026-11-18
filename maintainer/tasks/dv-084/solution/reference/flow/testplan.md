## T01

feature_ids: ["F01"]

requirement_ids: ["R-YAPP-001"]

stimulus: Assert reset high between edges while idle and while channel 2 has a backlog of 10 bytes, hold for 5 cycles, then release between edges; check that asynchronous clearing takes effect, and send packets with different contents after recovery. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: The falling edge of clock accepts input bytes, performs host accesses, and advances queues; outputs data_N and data_vld_N update after the rising edge. reset is an active-high asynchronous reset that immediately clears error and the three data_vld, in-flight packets, queues, counters, and interrupts, and restores configuration to max=63, enable=1, and ien=0. Release away from clock edges. No numerical value is guaranteed for data_N when data_vld_N=0, and RW memory is not initialized by reset.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V01

source: router_if.sv:pulse_reset; model_check.sv:model_check

## T02

feature_ids: ["F02"]

requirement_ids: ["R-YAPP-002"]

stimulus: Send packets of lengths 1, 4, 8, 18, and 63 to each destination 0/1/2, using 00/FF/alternating/random payloads; still send legal packets when enable=00 and 01; compare byte by byte using independent byte queues and check that non-target channels have no extra bytes. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: The low 2 bits of the header specify destination 0/1/2; 3 is illegal; the high 6 bits specify length. Send the header, length payload bytes, and one checksum byte sequentially while in_data_vld=1, then set valid=0 and in_data=0 for at least one falling edge. The length field only determines header legality and is not used to terminate a packet automatically. The legal range is 1..max; all valid bytes of a legal packet are sent in order only to the destination channel. Legal-length packets are also forwarded normally when enable.bit0=0; it must not be treated as a general routing disable.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V02

source: router_pkg.sv:s_f12_basic; model_check.sv:model_check

## T03

feature_ids: ["F03"]

requirement_ids: ["R-YAPP-003"]

stimulus: With max=8, apply the cross of address 3 and lengths 0/9, and legal addresses with lengths 0/9/12; then send good packets to confirm recovery, read the error counters, and check that no remnants of discarded packets remain in the output queues. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: Header address 3 takes precedence over length errors; packets with address 3, length 0, or length greater than max are discarded entirely from the header until valid is driven low, without writing any output queue. No end-of-packet error comparison is performed in the discard state; an illegal-address event counts only toward the illegal counter, not the length counter. A new packet can begin after a falling edge with valid=0.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V03

source: router_pkg.sv:s_f3_err; model_check.sv:model_check

## T04

feature_ids: ["F04"]

requirement_ids: ["R-YAPP-004"]

stimulus: Pause destination channels 0/1/2 individually, send packets of at least 18 bytes to fill the 16-deep queue, and hold the input byte until release; while draining, immediately send the next header for the same destination to trigger header waiting, and send a header for another destination to verify isolation. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: A header is accepted only when the target output queue is empty; otherwise, in_suspend is asserted with the valid header; non-target queues do not block this header. Once packet transfer has begun, in_suspend reflects the target 16-byte queue being full. The source holds valid and the current byte while paused, and advances only once after resumption. Finally driving valid low requires waiting for acceptance of the preceding valid byte; a packet cannot be terminated while input is paused.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V04

source: router_pkg.sv:susp_ep; model_check.sv:model_check

## T05

feature_ids: ["F05"]

requirement_ids: ["R-YAPP-005"]

stimulus: Alternate short packets and 63-byte packets across the three channels, pausing each for 28 cycles before release, covering write/read when empty, continuous writes/reads, writes only until full, reads only until drained, wraparound, only one byte remaining, and inter-packet waiting; check for no loss or duplication based on acceptance before the edge and stable data at the rising edge. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: Each channel has an independent capacity of 16 bytes. suspend_N=0 permits dequeueing on the falling edge; =1 prevents dequeueing. After the rising edge, data_N presents the byte at the current read position; data_vld_N is 1 when nonempty except when only one byte remains and there is no current write, so the extra in_data tail byte written at termination with valid=0 is not delivered as valid packet data. Pausing does not force data_vld to 0; the consumer records a byte once only when unpaused and valid. A simultaneous write/read on an empty queue stores first without dequeueing; a simultaneous write/read on a nonempty queue advances each once.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V05

source: router_pkg.sv:ch_mon; model_check.sv:model_check

## T06

feature_ids: ["F06"]

requirement_ids: ["R-YAPP-006"]

stimulus: For each destination, send checksums with the correct XOR and with FF flipped, with the terminating cycle set to 0; also cover all-zero, all-one, and differing data bytes, comparing error, the bytes still forwarded, and the error counters; check that error clears during subsequent idle cycles and new packets. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: Every falling edge with valid=1 and no input pause XORs in_data into the accumulated value, including the header, payload, valid checksum byte, and inputs of discarded packets; when valid=0 and packet transfer was just in progress, compare the accumulated value with in_data in that cycle, setting error=1 if unequal. The recommended valid checksum byte is the XOR of the header and payload, with in_data=0 in the terminating cycle. After an error, the next accepted byte or ordinary idle cycle clears error. Good packets do not report errors; packets with bad checksums are still forwarded.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V06

source: router_pkg.sv:s_f3_err; model_check.sv:model_check

## T07

feature_ids: ["F07"]

requirement_ids: ["R-YAPP-007"]

stimulus: Insert a falling edge with hen=0 before each access, and read 1000..100E, 1010/1050, 1100/11FF, 1007/1008/100E, and 0000/1200/3000; compare unmapped reads against four-state Z, and write RO to confirm writes are ignored. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: When hen=1, perform a read for hwr_rd=0 and a write for =1 on the falling edge. Allow at least one falling edge with hen=0 before every access to release the DUT's previous read drive; the host releases hdata only for reads and drives 8 bits for writes. Sample stably after the read and before the next falling edge. The range is 1000..2FFF; block 1000 maps registers, 1010..1050 maps read-only capture, and 1100..11FF maps RW memory. Unmapped registers return Z; other undecoded addresses retain the previous driven value, which is Z under the independent-access protocol above. A read-to-write transition without an idle interval can cause contention and is not legal stimulus for this task.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V07

source: router_pkg.sv:hbus_drv; model_check.sv:model_check

## T08

feature_ids: ["F08"]

requirement_ids: ["R-YAPP-008"]

stimulus: Configure max=8 and send lengths 7/8/9/0; write max=4, 63, and values with nonzero high bits to check masking; read and write enable bit by bit and with F7, 00, and 01, and send corresponding packets; read and write ien=0 and 7. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: 1000 controls maximum length in the low 6 bits, reads 0 in the high 2 bits, and resets to 63. Enable bits of 1001 are 7=illegal-address counting, 6/5/4=destination 2/1/0 counting, 2=length-error counting, 1=checksum-error counting, and 0=routing flag; bit3 is ignored and reads 0; the reset value is 01. 1002 contains interrupt enables in the low 3 bits (illegal/length/checksum), with high bits 0 and reset value 0. Only header length legality changes with max; there are no top-level parameters.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V08

source: router_pkg.sv:dvbench_test; model_check.sv:model_check

## T09

feature_ids: ["F09"]

requirement_ids: ["R-YAPP-009"]

stimulus: After enabling F7, generate each event type at least 8 times and read each counter; turn off each enable and repeat the corresponding event to confirm the count holds, then re-enable to continue counting; send packets while holding the error/address reset domains individually to confirm the corresponding group is 0 and other groups are unaffected. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: 1004/1005/1006 are checksum/length/illegal error counters; 1009/A/B are destination 0/1/2 packet counters, read-only, 8-bit, reset to 0. They accumulate only when the corresponding enable=1 and the corresponding reset domain is not held. Illegal headers and length-error headers are counted at header determination, destinations are counted upon legal header acceptance, and checksum errors are counted at the error comparison. Host-visible values pass through falling-edge snapshots; allow at least 3 idle falling edges before reading. When internal accumulation exceeds 255 and wraps, visible registers accept only larger values and are not guaranteed to return to zero until cleared by reset.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V09

source: router_pkg.sv:s_cov_cnt; model_check.sv:model_check

## T10

feature_ids: ["F10"]

requirement_ids: ["R-YAPP-010"]

stimulus: Generate the three errors with ien=0/7 and counting enabled/disabled; first read status, then write 02 to check that other bits hold, and write 07 to clear; after disabling ien, write 1 to check that existing status holds, clear after re-enabling, and selectively reset interrupts. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: 1003 reads status in the low 3 bits and 0 in the high 5 bits. A corresponding event sets the corresponding status only when both error counting and interrupts are enabled; a valid checksum error can still set error even with interrupts disabled. Status holds until reset or write-one-to-clear; W1C requires the corresponding interrupt enable to remain 1 and the status to be set; writing 0 or writing a disabled bit does not clear other status. Resetting the interrupt domain clears both status and enables. Allow at least 3 falling edges before and after reads/writes for the status mirror to stabilize.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V10

source: router_pkg.sv:dvbench_test; model_check.sv:model_check

## T11

feature_ids: ["F11"]

requirement_ids: ["R-YAPP-011"]

stimulus: Send a length-18 packet followed by a length-1 packet, and read 100D, the captured header and payload/checksum, and the residual tail of the previous packet; then send headers with different destinations and illegal addresses, and compare the capture against independent input history; after resetting the RAM domain, check that the capture is cleared while the length at 100D is retained. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: 100D reads the length from the high 6 bits of the first byte of the most recently accepted stream; 1010..1050 is a 65-byte read-only capture, cleared on reset. Capture follows all unpaused valid inputs, including illegal/discarded packets, with registered data written on the subsequent falling edge: the first byte sets the index to 0 and extracts the length; subsequent indices increase to length+1 and stop there, with subsequent bytes overwriting the final position. A shorter new packet does not clear the old tail; resetting the RAM domain clears capture but not the most recent length; allow at least 3 idle falling edges before reading. The terminating cycle is not a generally reliable source of additional checksum capture.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V11

source: router_pkg.sv:yapp_mon; model_check.sv:model_check

## T12

feature_ids: ["F12"]

requirement_ids: ["R-YAPP-012"]

stimulus: Write 00/FF/AA/55 to RW addresses 00/FF and random addresses, then read back; after reset, read the written addresses to confirm retention; successively write 1F, 00, 02, 04, 08, 10, and 00 to 100C, send packets and read affected/unaffected registers while held, and finally restore transmission. Insert a falling edge with hen=0 before every host access; at packet termination, valid=0 and in_data=0; release reset away from edges.

expected: 1100..11FF is 256 bytes of byte-by-byte RW storage; initial unwritten contents are not guaranteed; external/software reset does not clear this RW storage. 100C uses only the low 5 bits and holds until rewritten: bit0 resets all routing (FIFO/configuration/error and address counters/interrupts/capture) and requires writing 0 to release; bit1 continuously clears error counters, bit2 continuously clears address counters, bit3 clears interrupt status and enables, and bit4 clears capture RAM without clearing the most recent length. The independent domains do not prevent legal packet forwarding.

checker: Stabilize inputs before the falling edge and record acceptance; sample output data/valid 1ns after the rising edge, and error/host 1ns after the falling edge; for asynchronous reset, check valid/error 1ns later between edges. Record a byte only for a valid, unpaused output; use four-state logic for hdata. Build an independent model solely from actually driven inputs and their history, keeping actual and expected on separate paths; compare native ports, byte queues, counters, and registers within valid windows, without backfilling expected from DUT outputs. Issue UVM_ERROR for every mismatch and increment the check count; at completion, verify that queues are drained and counts are nonzero; there must be no always-pass behavior or coverage-only checking.

implementation_id: V12

source: router_pkg.sv:dvbench_test; model_check.sv:model_check
