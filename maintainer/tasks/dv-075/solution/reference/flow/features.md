# Features

## F01

requirement_ids: R-RDMA-001

module: axi_rdma

definition: Progress occurs on rising edges of aclk, and aresetn is asynchronous active-low. Reset sets cmd_ready=1, axi_m_arvalid=0, axi_m_arid=0, and dout_tvalid=0, and clears in-flight commands and buffered data. arsize is always 2, and arburst is always 1. No numerical values are guaranteed for araddr/arlen during reset or for invalid stream payloads; for valid output, compare only bytes with tkeep=1. Deassert reset away from clock edges; new commands can be accepted afterward.

interface: aclk, aresetn, cmd_ready, axi_m_arvalid, axi_m_arid, axi_m_arsize, axi_m_arburst, dout_tvalid, dout_tdata, dout_tkeep

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F02

requirement_ids: R-RDMA-002

module: axi_rdma

definition: Sample cmd_address/cmd_bytes on a rising edge when cmd_valid and cmd_ready are both 1. After acceptance, cmd_ready goes low, and the payload no longer needs to be held. No other command is accepted while a command is in flight; readiness is restored only after the final output beat is accepted. If the upstream handshake has not yet occurred, the upstream must hold valid and the payload and cannot queue commands by pulsing while busy; see the length clause for the zero-byte command exception.

interface: cmd_address, cmd_bytes, cmd_valid, cmd_ready, dout_tvalid, dout_tlast, dout_tready

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F03

requirement_ids: R-RDMA-003

module: axi_rdma

definition: The word width is fixed at 32 bits. Let o=cmd_address mod 4; when cmd_bytes=0, the read word count D=0; otherwise, first calculate L=cmd_bytes+o as a LENGTH_BITS-bit unsigned number (wrapping on overflow), and D=ceil(L/4). This task uses 32-bit addresses and lengths. After a zero-byte command is accepted, no AR is issued and no data is output, and readiness is subsequently restored. Addresses are aligned down to 4-byte boundaries and wrap according to the bit width when crossing the 32-bit address boundary; no read is issued either when a nonzero length plus the offset wraps to 0.

interface: cmd_address, cmd_bytes, cmd_valid, cmd_ready, axi_m_araddr, axi_m_arvalid, dout_tvalid

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F04

requirement_ids: R-RDMA-004

module: axi_rdma

definition: Each AR has ID=0, SIZE=2 (4 bytes), and BURST=1 (INCR). Split into segments according to the remaining read word count, with f=min(remaining,MAX_BURST) for each segment and ARLEN=f-1. The first segment address is the aligned command address, and subsequent addresses increment by 4f. There is no additional splitting at 4KiB boundaries. ARVALID is a registered output; once valid while ARREADY=0, the address, length, and valid are held. No AR is issued on the first rising edge after command acceptance; the first ARVALID is visible on the next rising edge. It is deasserted after the handshake, and one computation interval is used to schedule the next segment.

interface: axi_m_arid, axi_m_araddr, axi_m_arlen, axi_m_arsize, axi_m_arburst, axi_m_arvalid, axi_m_arready, cmd_address, cmd_bytes

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F05

requirement_ids: R-RDMA-005

module: axi_rdma

definition: Mask bit k in this clause corresponds to rdata[8k+:8], independent of memory endianness. For the first input word, if D>1, the mask selects k=o..3; if D=1, it selects k=o..min(o+n,4)-1, where n=cmd_bytes mod 4, and selection extends through 3 when n=0. For the last word that is not also the first word, the mask selects k=0..m-1, where m=(o+cmd_bytes) mod 4, and selects all when m=0. All intermediate words are fully selected. The first-word condition takes priority, so a single word is not additionally combined with the last-word mask.

interface: cmd_address, cmd_bytes, axi_m_rdata, axi_m_rvalid, axi_m_rready, dout_tkeep, dout_tdata

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F06

requirement_ids: R-RDMA-006

module: axi_rdma

definition: Select bytes in the order of accepted R words. When MEM_BIG_ENDIAN=TRUE, scan each word from the high byte to the low byte of rdata, retaining only lanes whose input mask bits are set; when FALSE, scan from low to high. Concatenate the selected bytes without gaps and output one beat per 4 bytes. When STREAM_BIG_ENDIAN=TRUE, the first byte occupies the high bits, and tkeep is contiguous at the high end; when FALSE, the first byte occupies the low bits, and tkeep is contiguous at the low end. If the final beat contains fewer than 4 bytes, only the corresponding lanes are valid. Big-endian unaligned/short-byte selection is jointly determined by this clause and the preceding clause and must not be replaced with an ideal address-range copy; for example, when o=0,B=1, select rdata[7:0] and then shift it to the high output byte.

interface: axi_m_rdata, axi_m_rvalid, axi_m_rready, dout_tdata, dout_tkeep, dout_tvalid, dout_tready, cmd_address, cmd_bytes

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F07

requirement_ids: R-RDMA-007

module: axi_rdma

definition: R input is accepted only on a rising edge when RVALID and RREADY are both 1. RREADY is constrained by the space in the reorderer and the 16-entry output buffer and cannot be treated as a simple wire connection to DOUT_TREADY; there is at least one startup wait edge after the first RVALID appears. The R producer must hold the payload during stalls. When DOUT_TVALID=1 and DOUT_TREADY=0, the valid payload and markers are held; after resumption, output proceeds in order, without loss or duplication. Output latency includes reordering and buffering; same-cycle pass-through on an R handshake must not be required.

interface: axi_m_rvalid, axi_m_rready, axi_m_rdata, dout_tdata, dout_tkeep, dout_tlast, dout_tvalid, dout_tready

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F08

requirement_ids: R-RDMA-008

module: axi_rdma

definition: The output of a nonzero command asserts dout_tlast only on the final valid beat, and the output beat count is the total number of selected bytes divided by 4, rounded up. The final input R word is determined by the local D count, not by RLAST; cmd_ready remains 0 until valid/ready are both 1 on the final output beat. A command must not end early when the completion marker is backpressured.

interface: cmd_ready, axi_m_rvalid, axi_m_rready, axi_m_rlast, dout_tvalid, dout_tlast, dout_tready, dout_tkeep

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F09

requirement_ids: R-RDMA-009

module: axi_rdma

definition: axi_m_rid, axi_m_rresp, and axi_m_rlast do not participate in data selection, counting, error handling, or completion determination. This module has no error response or cancellation port. Supply exactly the required R data in the order of the AR segments already issued; do not send an isolated RVALID when no command is in flight, and do not send extra or missing beats. Changing these sideband fields does not change the output for the same data and timing.

interface: axi_m_rid, axi_m_rresp, axi_m_rlast, axi_m_rvalid, axi_m_rdata, dout_tdata, dout_tkeep, dout_tlast, dout_tvalid

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.

## F10

requirement_ids: R-RDMA-010

module: axi_rdma

definition: The native default parameters of the top-level axi_rdma are ADDRESS_BITS=32, LENGTH_BITS=32, MAX_BURST=256, MEM_BIG_ENDIAN=TRUE, and STREAM_BIG_ENDIAN=TRUE. This task fixes addresses and lengths at 32 bits; the same submission must verify two complete top-level instances, BE16 (big-endian at both ends, MAX_BURST=16) and LE256 (little-endian at both ends, MAX_BURST=256), and the model supports the corresponding parameters. Asynchronous reset aborts all in-flight operations, and new commands after recovery are independent; there is no need to wait for old R responses or output to complete, and the external environment must also stop the canceled R responses.

interface: aclk, aresetn, cmd_valid, cmd_ready, axi_m_arvalid, axi_m_rvalid, dout_tvalid

timing: Interpret according to the asynchronous reset, rising-edge handshakes, and valid windows explicitly specified in this clause; do not compare invalid fields.

boundary: The scope is the 32-bit addresses and lengths, BE16, and LE256 of this task; the number of legal R responses must match the commands issued.
