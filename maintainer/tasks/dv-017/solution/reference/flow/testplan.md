# Verification Plan Reference

## T1

Function: F1; requirement: R-dv-017-sram-arbiter-001.

Stimulus: Run three configurations in parallel. After clean_reset, drive the low/high single ports, two-port contention, and continuous writes on all ports for 3*N cycles, then run 1200 random cycles, replacing requests and payload every N cycles; sample #1 after driving at each negedge.

Expected: sram_req_o combinationally equals the OR of all bits of req_i. With no requests, gnt_o is all zeros; with requests, exactly one bit is set and its corresponding request is asserted. After reset, the lowest index has priority. After each rising edge of clk_i with a request, the next selection first considers requests at higher indices after the current winner, wrapping around to the lowest index if none exist; idle edges retain the next priority. Read/write type does not change arbitration priority. There is no SRAM ready or backpressure; one command is issued on every rising edge with a request. Requests may change between acceptance edges, and remaining high allows commands to be formed repeatedly on subsequent edges.

Checks: sram_monitor.run_phase captures actual and the independent dvbench_model outputs #1 after driving at negedge; sram_scoreboard.write uses !== to compare grant/request/responsevalid field by field, compares addr/write/wdata/wmask for valid commands, and compares all data/error broadcasts on every cycle. The model uses only the original inputs and their history. Mismatches produce UVM_ERROR, with at most 30 error messages but a complete server error count; check_phase requires samples>=1200, nonzero commands and returns, hits on the first-cycle read and full pop/push, and final draining.

Implementation: tb/sram_uvm.sv — sram_sequence.body + sram_scoreboard.write + sram_scoreboard.check_phase.

## T2

Function: F2; requirement: R-dv-017-sram-arbiter-002.

Stimulus: Drive port0 sequentially with addresses 0/fff, data 0/all ones, and mask 0/all ones, then use addresses 123/321, 55AA33CC/CC33AA55, and 00FF0FF0/FF00F00F; the two contending ports have different read/write types and payloads. Execute in all three configurations.

Expected: During a valid command window with sram_req_o equal to 1, sram_addr_o, sram_write_o, and sram_wdata_o equal the granted port's req_addr_i, req_write_i, and req_wdata_i, respectively. When EnMask=1, sram_wmask_o equals the granted port's req_wmask_i; when EnMask=0, sram_wmask_o for a valid command is all ones. With no request, the command payload is not part of a valid command, and no functional requirements are imposed on these payload fields.

Checks: sram_monitor.run_phase captures actual and the independent dvbench_model outputs #1 after driving at negedge; sram_scoreboard.write uses !== to compare grant/request/responsevalid field by field, compares addr/write/wdata/wmask for valid commands, and compares all data/error broadcasts on every cycle. The model uses only the original inputs and their history. Mismatches produce UVM_ERROR, with at most 30 error messages but a complete server error count; check_phase requires samples>=1200, nonzero commands and returns, hits on the first-cycle read and full pop/push, and final draining.

Implementation: tb/sram_uvm.sv — sram_sequence.body + sram_scoreboard.write + sram_scoreboard.check_phase.

## T3

Function: F3; requirement: R-dv-017-sram-arbiter-003.

Stimulus: After reset warm-up, issue reads from ports 0 and 1 in sequence, return distinct data consecutively, then provide an additional return with an empty queue; separately, after read A in the first cycle after release and read B in the second cycle, provide returns and check that the first owner is B and valid is subsequently 0. The 1200 random cycles provide a new read and a return in the same cycle with an empty queue.

Expected: Only read commands retain the granted port as an outstanding read owner; write commands do not retain an owner. Except for the first edge after reset release and windows when capacity is full, read owners are added to an ordered queue on rising edges of clk_i. When the queue is nonempty and sram_rvalid_i is 1, rsp_rvalid_o combinationally equals the one-hot vector of the earliest owner, and that owner is removed on that rising edge; when sram_rvalid_i is 0, rsp_rvalid_o is all zeros. An empty queue does not produce any port valid even if sram_rvalid_i is 1. Issuing a new read and a return in the same cycle with an empty queue does not bypass the new owner; the new owner can become the queue head only after the acceptance edge.

Checks: sram_monitor.run_phase captures actual and the independent dvbench_model outputs #1 after driving at negedge; sram_scoreboard.write uses !== to compare grant/request/responsevalid field by field, compares addr/write/wdata/wmask for valid commands, and compares all data/error broadcasts on every cycle. The model uses only the original inputs and their history. Mismatches produce UVM_ERROR, with at most 30 error messages but a complete server error count; check_phase requires samples>=1200, nonzero commands and returns, hits on the first-cycle read and full pop/push, and final draining.

Implementation: tb/sram_uvm.sv — sram_sequence.body + sram_scoreboard.write + sram_scoreboard.check_phase.

## T4

Function: F4; requirement: R-dv-017-sram-arbiter-004.

Stimulus: Fill with four reads without returns, then issue an additional read, then rv=1 simultaneously with a new read, followed by non-full pop/push, and finally five returns; compare all return valid signals cycle by cycle.

Expected: At most four outstanding read owners are retained. When four entries are already present, further read commands still receive a grant and an SRAM request, but the new owner is discarded, without applying backpressure or producing a dedicated error signal. Acceptance capacity is determined from occupancy before the rising edge: when previously full and an old read returns in the same cycle as a new read is issued, the old owner is removed but the new owner is still discarded; when previously non-full and nonempty, a simultaneous return and new read maintain occupancy, appending the new owner to the tail.

Checks: sram_monitor.run_phase captures actual and the independent dvbench_model outputs #1 after driving at negedge; sram_scoreboard.write uses !== to compare grant/request/responsevalid field by field, compares addr/write/wdata/wmask for valid commands, and compares all data/error broadcasts on every cycle. The model uses only the original inputs and their history. Mismatches produce UVM_ERROR, with at most 30 error messages but a complete server error count; check_phase requires samples>=1200, nonzero commands and returns, hits on the first-cycle read and full pop/push, and final draining.

Implementation: tb/sram_uvm.sv — sram_sequence.body + sram_scoreboard.write + sram_scoreboard.check_phase.

## T5

Function: F5; requirement: R-dv-017-sram-arbiter-005.

Stimulus: With rv=0, iterate through the four error codes, with rd equal to 13579BDF XORed with different patterns; also change data/error for normal returns, empty-queue returns, and returns during reset, comparing all N outputs.

Expected: rsp_rdata_o of every port always combinationally equals sram_rdata_i, and rsp_error_o of every port always combinationally equals sram_rerror_i; all four two-bit error codes propagate unchanged. This broadcast relationship holds regardless of which owner is valid, whether there are outstanding reads, whether return valid is high or low, or whether reset is asserted. This module does not implement SRAM storage contents or correct error codes.

Checks: sram_monitor.run_phase captures actual and the independent dvbench_model outputs #1 after driving at negedge; sram_scoreboard.write uses !== to compare grant/request/responsevalid field by field, compares addr/write/wdata/wmask for valid commands, and compares all data/error broadcasts on every cycle. The model uses only the original inputs and their history. Mismatches produce UVM_ERROR, with at most 30 error messages but a complete server error count; check_phase requires samples>=1200, nonzero commands and returns, hits on the first-cycle read and full pop/push, and final draining.

Implementation: tb/sram_uvm.sv — sram_sequence.body + sram_scoreboard.write + sram_scoreboard.check_phase.

## T6

Function: F6; requirement: R-dv-017-sram-arbiter-006.

Stimulus: After holding reset low for two cycles, release it and drive read A in the first cycle, a different owner B in the second cycle, and then returns; additionally, after generating two outstanding reads, pull reset low at negedge while maintaining nonzero requests and returns, release it with requests present, and resume returns.

Expected: Low rst_ni is an asynchronous reset that clears all read owners and restores the next priority to the lowest index. Reset does not mask combinational requests or grants; nonzero req_i during reset still produces sram_req_o and one-hot gnt_o, but no read owner is retained. The first rising edge of clk_i after release performs arbitration and advances priority but does not accept a read owner; normal owner retention starts only at the second rising edge. Reset discards the previously outstanding reads, and a return with an empty queue after reset does not produce any port valid.

Checks: sram_monitor.run_phase captures actual and the independent dvbench_model outputs #1 after driving at negedge; sram_scoreboard.write uses !== to compare grant/request/responsevalid field by field, compares addr/write/wdata/wmask for valid commands, and compares all data/error broadcasts on every cycle. The model uses only the original inputs and their history. Mismatches produce UVM_ERROR, with at most 30 error messages but a complete server error count; check_phase requires samples>=1200, nonzero commands and returns, hits on the first-cycle read and full pop/push, and final draining.

Implementation: tb/sram_uvm.sv — sram_sequence.body + sram_scoreboard.write + sram_scoreboard.check_phase.

## T7

Function: F7; requirement: R-dv-017-sram-arbiter-007.

Stimulus: Instantiate N4PPC0, N4PPC1, and N2BINTREE1 in parallel at the top level, with model parameters identical to those of the DUT. Each executes the full sequence and 1200 random cycles; the final eight cycles consist of four returns followed by four idle cycles.

Expected: This problem includes three configurations: N=4, SramAw=12, SramDw=32, ArbiterImpl set to PPC, EnMask=0 (default); the same widths with N=4, PPC, EnMask=1; and N=2, the same address and data widths, BINTREE, EnMask=1. Both arbitration implementations follow the same round-robin and response contract, with masks handled according to EnMask. Other parameter points are outside the scope of this problem. Inputs are known two-state values and are stable around the accepting rising edge; combinational relationships are observable after stable inputs have propagated. The return stream is consumed in retained-owner order, without identifying the source from the data.

Checks: sram_monitor.run_phase captures actual and the independent dvbench_model outputs #1 after driving at negedge; sram_scoreboard.write uses !== to compare grant/request/responsevalid field by field, compares addr/write/wdata/wmask for valid commands, and compares all data/error broadcasts on every cycle. The model uses only the original inputs and their history. Mismatches produce UVM_ERROR, with at most 30 error messages but a complete server error count; check_phase requires samples>=1200, nonzero commands and returns, hits on the first-cycle read and full pop/push, and final draining.

Implementation: tb/sram_uvm.sv — sram_sequence.body + sram_scoreboard.write + sram_scoreboard.check_phase.

