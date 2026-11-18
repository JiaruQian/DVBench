# Testplan

## T01

feature_ids: F01

requirement_ids: R-RDMA-001

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. First complete a short command, then asynchronously assert reset low separately during the AR, R, and output-stall phases of a long command, deassert it on a falling edge, and send another command with different data; check clearing and recovery.

expected: Progress occurs on rising edges of aclk, and aresetn is asynchronous active-low. Reset sets cmd_ready=1, axi_m_arvalid=0, axi_m_arid=0, and dout_tvalid=0, and clears in-flight commands and buffered data. arsize is always 2, and arburst is always 1. No numerical values are guaranteed for araddr/arlen during reset or for invalid stream payloads; for valid output, compare only bytes with tkeep=1. Deassert reset away from clock edges; new commands can be accepted afterward.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V01

source: rdma_if.sv:pulse_reset

## T02

feature_ids: F02

requirement_ids: R-RDMA-002

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. Send successive commands with different addresses and lengths, changing the payload after each handshake; while output is blocked, hold the next cmd_valid, confirm that it is not accepted early, and accept it only after the final beat has drained.

expected: Sample cmd_address/cmd_bytes on a rising edge when cmd_valid and cmd_ready are both 1. After acceptance, cmd_ready goes low, and the payload no longer needs to be held. No other command is accepted while a command is in flight; readiness is restored only after the final output beat is accepted. If the upstream handshake has not yet occurred, the upstream must hold valid and the payload and cannot queue commands by pulsing while busy; see the length clause for the zero-byte command exception.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V02

source: rdma_pkg.sv:cmd_drv/seq_stress

## T03

feature_ids: F03

requirement_ids: R-RDMA-003

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. Sweep o=0..3 and lengths 0..8, 63..65, 1024, 1025, and 2048; also use lengths near the 32-bit upper limit to check no reads or short reads after wraparound, and reset extremely long commands after only a finite prefix.

expected: The word width is fixed at 32 bits. Let o=cmd_address mod 4; when cmd_bytes=0, the read word count D=0; otherwise, first calculate L=cmd_bytes+o as a LENGTH_BITS-bit unsigned number (wrapping on overflow), and D=ceil(L/4). This task uses 32-bit addresses and lengths. After a zero-byte command is accepted, no AR is issued and no data is output, and readiness is subsequently restored. Addresses are aligned down to 4-byte boundaries and wrap according to the bit width when crossing the 32-bit address boundary; no read is issued either when a nonzero length plus the offset wraps to 0.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V03

source: rdma_pkg.sv:seq_zero/seq_single/seq_bigcap

## T04

feature_ids: F04

requirement_ids: R-RDMA-004

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. For the two parameterized instances, respectively sweep read word counts below and above MAX_BURST, including 15/16/17 and 255/256/257/512 words; randomly delay ARREADY by 0 or 2 cycles, independently build an expected AR queue per command, and check address continuity and constants.

expected: Each AR has ID=0, SIZE=2 (4 bytes), and BURST=1 (INCR). Split into segments according to the remaining read word count, with f=min(remaining,MAX_BURST) for each segment and ARLEN=f-1. The first segment address is the aligned command address, and subsequent addresses increment by 4f. There is no additional splitting at 4KiB boundaries. ARVALID is a registered output; once valid while ARREADY=0, the address, length, and valid are held. No AR is issued on the first rising edge after command acceptance; the first ARVALID is visible on the next rising edge. It is deasserted after the handshake, and one computation interval is used to schedule the next segment.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V04

source: rdma_pkg.sv:seq_big0/seq_multib/seq_bigcap/axi_slv

## T05

feature_ids: F05

requirement_ids: R-RDMA-005

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. Exhaust all 16 combinations of the 4 offsets and the low 2 length bits, and additionally cover the 10 single-word cases with o+B<=4, short commands crossing word boundaries, and multiword tails. Use returned data with every byte distinct and verify selection according to the mask.

expected: Mask bit k in this clause corresponds to rdata[8k+:8], independent of memory endianness. For the first input word, if D>1, the mask selects k=o..3; if D=1, it selects k=o..min(o+n,4)-1, where n=cmd_bytes mod 4, and selection extends through 3 when n=0. For the last word that is not also the first word, the mask selects k=0..m-1, where m=(o+cmd_bytes) mod 4, and selects all when m=0. All intermediate words are fully selected. The first-word condition takes priority, so a single word is not additionally combined with the last-word mask.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V05

source: rdma_pkg.sv:seq_sweep16/seq_single/rdma_sb

## T06

feature_ids: F06

requirement_ids: R-RDMA-006

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. Run both endianness instances with all-zero, all-one, byte-distinct, and random memory, crossing offsets 0..3, short tails of 1/2/3 bytes, and long frames; use an independent byte queue to calculate each valid lane, leaving invalid lanes un-compared.

expected: Select bytes in the order of accepted R words. When MEM_BIG_ENDIAN=TRUE, scan each word from the high byte to the low byte of rdata, retaining only lanes whose input mask bits are set; when FALSE, scan from low to high. Concatenate the selected bytes without gaps and output one beat per 4 bytes. When STREAM_BIG_ENDIAN=TRUE, the first byte occupies the high bits, and tkeep is contiguous at the high end; when FALSE, the first byte occupies the low bits, and tkeep is contiguous at the low end. If the final beat contains fewer than 4 bytes, only the corresponding lanes are valid. Big-endian unaligned/short-byte selection is jointly determined by this clause and the preceding clause and must not be replaced with an ideal address-range copy; for example, when o=0,B=1, select rdata[7:0] and then shift it to the high output byte.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V06

source: rdma_pkg.sv:seq_f02/seq_deep/rdma_sb

## T07

feature_ids: F07

requirement_ids: R-RDMA-007

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. First pull dout_tready low for 30 clocks to allow filling with more than 68 bytes of traffic, then restore it; supplement with 60% random ready and R inter-beat gaps of 0/1, checking stall stability, bounded recovery, and complete ordered data.

expected: R input is accepted only on a rising edge when RVALID and RREADY are both 1. RREADY is constrained by the space in the reorderer and the 16-entry output buffer and cannot be treated as a simple wire connection to DOUT_TREADY; there is at least one startup wait edge after the first RVALID appears. The R producer must hold the payload during stalls. When DOUT_TVALID=1 and DOUT_TREADY=0, the valid payload and markers are held; after resumption, output proceeds in order, without loss or duplication. Output latency includes reordering and buffering; same-cycle pass-through on an R handshake must not be required.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V07

source: rdma_pkg.sv:seq_fill16/out_drv;rdma_if.sv:a_do_stable

## T08

feature_ids: F08

requirement_ids: R-RDMA-008

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. Send commands of 1, 4, 5, 67, and 68 bytes, stall the expected final beat for 2..8 cycles, and check last/keep stability and that cmd_ready does not occur early; after resumption, verify a unique final beat, the total R word count, and the total AR segment count.

expected: The output of a nonzero command asserts dout_tlast only on the final valid beat, and the output beat count is the total number of selected bytes divided by 4, rounded up. The final input R word is determined by the local D count, not by RLAST; cmd_ready remains 0 until valid/ready are both 1 on the final output beat. A command must not end early when the completion marker is backpressured.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V08

source: rdma_pkg.sv:rdma_sb.write_do/seq_deep

## T09

feature_ids: F09

requirement_ids: R-RDMA-009

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. With the same RDATA and timing, separately provide OKAY, SLVERR, DECERR, EXOKAY, varying RID, and RLAST unrelated to the data endpoint; use an input-history oracle to compare the complete output rather than waiting for an error port.

expected: axi_m_rid, axi_m_rresp, and axi_m_rlast do not participate in data selection, counting, error handling, or completion determination. This module has no error response or cancellation port. Supply exactly the required R data in the order of the AR segments already issued; do not send an isolated RVALID when no command is in flight, and do not send extra or missing beats. Changing these sideband fields does not change the output for the same data and timing.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V09

source: rdma_pkg.sv:seq_err/axi_slv

## T10

feature_ids: F10

requirement_ids: R-RDMA-010

stimulus: Reset and wait for readiness; drive on falling edges or through a clocking block. Fully instantiate BE16 and LE256 and send long commands spanning segments; reset during filling, R waiting, and output blocking, cancel old responses externally in coordination, and then rerun short commands with different data.

expected: The native default parameters of the top-level axi_rdma are ADDRESS_BITS=32, LENGTH_BITS=32, MAX_BURST=256, MEM_BIG_ENDIAN=TRUE, and STREAM_BIG_ENDIAN=TRUE. This task fixes addresses and lengths at 32 bits; the same submission must verify two complete top-level instances, BE16 (big-endian at both ends, MAX_BURST=16) and LE256 (little-endian at both ends, MAX_BURST=256), and the model supports the corresponding parameters. Asynchronous reset aborts all in-flight operations, and new commands after recovery are independent; there is no need to wait for old R responses or output to complete, and the external environment must also stop the canceled R responses.

checker: Independently generate expectations from the history of commands and driven R data; confirm acceptance on rising edges, and compare actual valid lanes, keep, last, and AR fields in stable windows without backfilling expectations from DUT outputs. Report differences with UVM_ERROR, count comparisons, and check that nothing remains after draining.

implementation_id: V10

source: top.sv;rdma_pkg.sv:test_base/dvbench_test
