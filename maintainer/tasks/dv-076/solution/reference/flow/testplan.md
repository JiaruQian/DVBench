## T-1
feature_ids: ["F-1"]
requirement_ids: ["R-dv-076-001"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. Run the complete system from reset to the end of the firmware, keeping the external input variable.
expected: The top level for this task is the complete five-stage pipeline pipelined_riscv_core, with fixed WIDTH=32 and PROGRAM_FILE="program3.hex"; replacing the program is not allowed. ROM and RAM each contain 256 32-bit words, and unlisted ROM locations contain NOP. The public program listing defines the software scope of this task; support for arbitrary RV32I programs need not be guaranteed. Use only known two-state inputs.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-1
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write

## T-2
feature_ids: ["F-2"]
requirement_ids: ["R-dv-076-002"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. Apply reset separately at power-up, before and after sampling, before and after output, and during prolonged idle periods, including short pulses that do not span a rising edge and low levels spanning multiple clocks.
expected: i_rstn is an active-low asynchronous reset; its falling edge immediately clears result_valid and result_data, and clears the pipeline, PC, registers, and RAM. Generate at least one actual reset falling edge; all outputs are 0 during reset. Release reset away from a clock rising edge; the next rising edge counts as edge 1.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-2
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write

## T-3
feature_ids: ["F-3"]
requirement_ids: ["R-dv-076-003"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. Each legal run starts with a fresh reset; change the input before and after the sampling window, and use multiple resets to check that old RAM and register state does not leak.
expected: Byte address fffffff8 is read-only input_data, and fffffffc is the result register; neither writes ordinary RAM. The datapath uses 32-bit full-word reads and writes, and the ordinary RAM word index is the byte address shifted right by 2. The fixed firmware accesses only RAM word 0, writing before reading; there are no externally modifiable code or memory ports.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-3
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write

## T-4
feature_ids: ["F-4"]
requirement_ids: ["R-dv-076-004"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. Use distinct patterns on edges 20, 21, and 22, and keep changing the input on other edges; cover constant input and input that changes every cycle.
expected: On the 21st i_clk rising edge after each reset release, sample input_data as the 32-bit unsigned bit vector for this transaction; it is stable before the edge and held through that edge. Inputs at other times do not affect this result. A run canceled by reset before sampling produces no result; each run samples only once.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-4
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write

## T-5
feature_ids: ["F-5"]
requirement_ids: ["R-dv-076-005"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. Inputs cover 0, fffffffb, fffffffc, ffffffff, 7fffffff, 80000000, alternating bits, single-set-bit patterns, and random 32-bit values.
expected: The firmware sets x8=-8, reads input_data into x9, computes x10=x9+7, writes RAM word 0 and reads it back into x11, computes x11=x11-3, and writes to the result address; all operations are truncated to 32 bits modulo 2^32. Therefore, the result is the input at edge 21 plus 4 modulo 2^32, with no saturation or signed truncation.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-5
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write

## T-6
feature_ids: ["F-6"]
requirement_ids: ["R-dv-076-006"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. In a complete run, observe edges 65, 66, and 67 and at least several hundred later cycles; also reset after edge 65 to verify that no late output occurs.
expected: If reset does not interrupt the run, after the 66th rising edge result_valid is 1 and result_data is updated to the result of this run; result_valid is 0 on edges 1 through 65 and on edge 67 and thereafter it is 0. Even if the input remains unchanged, only one single-cycle pulse is produced. After the rising edge, wait for nonblocking assignments to settle before observing.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-6
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write

## T-7
feature_ids: ["F-7"]
requirement_ids: ["R-dv-076-007"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. After the result, continue changing the input and run for hundreds of cycles, checking on every cycle that data is held and valid is 0; then reset and rerun with a different input.
expected: result_data remains 0 after reset until the first result, and after being updated on edge 66, continues to hold the result, including on all edges where result_valid is 0; it is cleared only by the next reset. The JAL self-loop at the end of the firmware no longer writes the result and does not produce repeated outputs due to subsequent input_data changes. Both result_valid and result_data are public state valid on every cycle.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-7
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write

## T-8
feature_ids: ["F-8"]
requirement_ids: ["R-dv-076-008"]
stimulus: First drive reset low on a falling edge to establish a known state, then release it on a clock falling edge. Cancel after edges 20, 21, 65, 66, and 67 respectively, alternate short/long resets, and restart with distinct inputs to confirm that old samples are not reused across runs.
expected: An active reset at any time cancels the old run, with no queuing or subsequent delivery of old results; after release, restart counting from edge 1. This includes resets after sampling but before output, immediately after edge 66, and during the long-running tail loop. The new result comes only from the input at edge 21 of the new run.
checker: Edge numbering starts at edge 1 after reset release; the input is stable before the rising edge, and comparison occurs 1ns after the edge; after the reset falling edge, also compare before the next clock. Independently predict valid/data from the reset and input history, perform four-state comparisons of all outputs after every clock edge, and report UVM_ERROR on a mismatch; also compare between reset edges. Count complete result events, cancellations, and comparisons; passing with no activity is prohibited.
implementation_id: V-8
source: firmware_reference.sv:firmware_driver.run_phase/firmware_scoreboard.write
