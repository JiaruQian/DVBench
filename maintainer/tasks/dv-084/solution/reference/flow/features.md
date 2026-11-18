## F01

requirement_ids: ["R-YAPP-001"]

module: yapp_router

interface: ["clock", "reset", "error", "data_vld_0", "data_vld_1", "data_vld_2", "data_0", "data_1", "data_2"]

definition: The falling edge of clock accepts input bytes and host accesses and advances queues; outputs data_N and data_vld_N update after the rising edge. reset is an active-high asynchronous reset that immediately clears error, the three data_vld, in-flight packets, queues, counts, and interrupts, and restores configuration to max=63, enable=1, ien=0. Release it away from clock edges. The value of data_N when data_vld_N=0 is not guaranteed, and RW memory is not initialized by reset.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F02

requirement_ids: ["R-YAPP-002"]

module: yapp_router

interface: ["in_data", "in_data_vld", "in_suspend", "data_0", "data_1", "data_2", "data_vld_0", "data_vld_1", "data_vld_2", "haddr", "hdata", "hen", "hwr_rd"]

definition: The low 2 header bits specify destination 0/1/2, with 3 illegal; the high 6 bits specify length. Send the header, length payload bytes, and one checksum byte sequentially, all while in_data_vld=1, then set valid=0 and in_data=0 for at least one falling edge. The length field only determines header legality and does not automatically terminate the packet. The legal range is 1..max; all valid bytes of a legal packet are sent in order only to the destination channel. Legal-length packets are still forwarded normally when enable.bit0=0; this must not be treated as a general routing disable.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F03

requirement_ids: ["R-YAPP-003"]

module: yapp_router

interface: ["in_data", "in_data_vld", "error", "data_vld_0", "data_vld_1", "data_vld_2", "haddr", "hdata", "hen", "hwr_rd"]

definition: Header address 3 takes priority over a length error; packets with address 3, length 0, or length greater than max are discarded in full from the header until valid is deasserted, without writing to any output queue. The discard state does not perform the end-of-packet error comparison; an illegal-address event contributes only to the illegal count, not the length count. A new packet may begin after a falling edge with valid=0.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F04

requirement_ids: ["R-YAPP-004"]

module: yapp_router

interface: ["in_data", "in_data_vld", "in_suspend", "suspend_0", "suspend_1", "suspend_2", "data_vld_0", "data_vld_1", "data_vld_2"]

definition: A header is accepted only when the destination output queue is empty; otherwise, in_suspend asserts with the valid header. Non-destination queues do not block that header. Once packet transfer has begun, in_suspend indicates that the destination 16-byte queue is full. The source holds valid and the current byte during suspension and advances only once after resumption. Finally deasserting valid must wait until the preceding valid byte has been accepted; a packet must not end during input suspension.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F05

requirement_ids: ["R-YAPP-005"]

module: yapp_router

interface: ["clock", "data_0", "data_1", "data_2", "data_vld_0", "data_vld_1", "data_vld_2", "suspend_0", "suspend_1", "suspend_2"]

definition: Each channel has an independent 16-byte capacity. suspend_N=0 allows dequeueing on falling edges, while =1 prevents dequeueing. After a rising edge, data_N presents the byte at the current read position; data_vld_N is 1 when nonempty except when only one byte remains and there is no current write, so the extra trailing in_data byte written at termination with valid=0 is not delivered as valid packet data. Suspension does not force data_vld to 0; the consumer records a byte only when not suspended and valid. For simultaneous write and read to an empty queue, the byte is stored without dequeueing; for a nonempty queue, write and read each advance once.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F06

requirement_ids: ["R-YAPP-006"]

module: yapp_router

interface: ["clock", "in_data", "in_data_vld", "in_suspend", "error", "haddr", "hdata", "hen", "hwr_rd"]

definition: On every falling edge with valid=1 and no input suspension, in_data is XORed into the accumulator, including the header, payload, valid checksum byte, and inputs of discarded packets; when valid=0 and packet transfer was just in progress, the accumulator is compared with in_data of that cycle, and if unequal, error=1. The recommended valid checksum byte is the XOR of the header and payload, with in_data=0 on the terminating cycle. After an error, the next accepted byte or ordinary idle cycle clears error. Good packets do not report an error, and packets with bad checksums are still forwarded.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F07

requirement_ids: ["R-YAPP-007"]

module: yapp_router

interface: ["clock", "haddr", "hdata", "hen", "hwr_rd"]

definition: When hen=1, hwr_rd=0 performs a read and =1 performs a write on the falling edge. Before each access, leave at least one falling edge with hen=0 to release the DUT's old read drive; the host releases hdata only for reads and drives 8 bits for writes. Sample stably after the read and before the next falling edge. The range is 1000..2FFF; block 1000 maps registers, 1010..1050 maps read-only capture, and 1100..11FF maps RW memory. Unmapped registers return Z; other undecoded addresses retain the previous driven value, which is Z when using the independent-access protocol above. A read-to-write transition without an idle gap can cause contention and is not a legal drive sequence for this task.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F08

requirement_ids: ["R-YAPP-008"]

module: yapp_router

interface: ["haddr", "hdata", "hen", "hwr_rd", "in_data", "in_data_vld"]

definition: 1000 controls maximum length in the low 6 bits, reads 0 in the high 2 bits, and resets to 63. 1001 enable bits are bit7=illegal-address count, 6/5/4=destination 2/1/0 counts, 2=length-error count, 1=checksum-error count, and 0=routing flag; bit3 is ignored and reads 0, and the reset value is 01. 1002 contains interrupt enables in the low 3 bits (illegal/length/checksum), with high bits 0 and reset value 0. Only header-length legality changes with max; there are no top-level parameters.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F09

requirement_ids: ["R-YAPP-009"]

module: yapp_router

interface: ["in_data", "in_data_vld", "error", "haddr", "hdata", "hen", "hwr_rd"]

definition: 1004/1005/1006 are checksum/length/illegal error counts; 1009/A/B are packet counts for destinations 0/1/2, read-only 8-bit values that reset to 0. They accumulate only when the corresponding enable=1 and the corresponding reset domain is not held in reset. Illegal headers and length-error headers are counted at header evaluation, destination counts increment on legal-header acceptance, and checksum counts increment at the error comparison. Host-visible values pass through falling-edge snapshots; allow at least 3 idle falling edges before reading. When internal accumulation exceeds 255 and wraps, visible registers accept only larger values and are not guaranteed to return to zero until cleared by reset.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F10

requirement_ids: ["R-YAPP-010"]

module: yapp_router

interface: ["in_data", "in_data_vld", "error", "haddr", "hdata", "hen", "hwr_rd"]

definition: 1003 reads status in the low 3 bits and 0 in the high 5 bits. A corresponding event sets its status only when both error-count enable and interrupt enable are active; a valid checksum error can still set error even when interrupts are disabled. Status persists until reset or write-one-to-clear; W1C requires the corresponding interrupt enable to remain 1 and the status to be set already. Writing 0 or writing a disabled bit does not clear other status bits. Resetting the interrupt domain clears both status and enables. Leave at least 3 falling edges before and after reads and writes for the status mirror to stabilize.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F11

requirement_ids: ["R-YAPP-011"]

module: yapp_router

interface: ["in_data", "in_data_vld", "in_suspend", "haddr", "hdata", "hen", "hwr_rd"]

definition: 100D reads the length from the high 6 bits of the first byte of the most recently accepted stream; 1010..1050 is a 65-byte read-only capture that resets to zero. Capture follows all valid, unsuspended input, including illegal/discarded packets, and registered data is written on the subsequent falling edge: the first byte sets the index to 0 and extracts the length, and subsequent indices increase to length+1 and then remain at that position, with subsequent bytes overwriting the final position. A shorter new packet does not clear the old tail. A RAM-domain reset clears the capture but not the most recent length; allow at least 3 idle falling edges before reading. The terminating cycle is not a generally reliable source of an additional checksum capture.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None

## F12

requirement_ids: ["R-YAPP-012"]

module: yapp_router

interface: ["reset", "haddr", "hdata", "hen", "hwr_rd", "in_data", "in_data_vld", "data_vld_0", "data_vld_1", "data_vld_2"]

definition: 1100..11FF is 256 bytes of byte-wise RW storage; initially unwritten contents are not guaranteed, and external/software reset does not clear this RW storage. 100C uses only the low 5 bits and retains its value until rewritten: bit0 resets the entire router (FIFO/configuration/error and address counts/interrupts/capture) and requires writing 0 to release; bit1 continuously clears error counts, bit2 continuously clears address counts, bit3 clears interrupt status and enables, and bit4 clears capture RAM without clearing the most recent length. The individual independent domains do not prevent legal packet forwarding.

timing: Observe the falling-edge acceptance, rising-edge output, and asynchronous reset windows described in this item.

boundary: Applies to legal valid inputs and the specified register addresses; do not compare invalid data, and unwritten RW data is not guaranteed.

parent_id: None
