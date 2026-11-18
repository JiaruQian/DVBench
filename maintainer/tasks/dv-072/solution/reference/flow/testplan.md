## T-106-001

feature_ids: F-106-001

requirement_ids: R-N106-001

stimulus: First complete one operation, then drive rst_n low between edges and check ready; separately, interrupt encryption on cycle 5, then release reset and complete a new operation.

expected: Operates on the rising edge of clk; rst_n is asynchronous and active-low. Reset immediately sets desc_ready=1 and cancels unfinished operations. desc_result has no reset guarantee; interpret the result only after a complete operation finishes following the current reset and during the subsequent idle period; do not check the result between starting a new operation and completion. Inputs are definite 0/1 values, established before the edge; separate the reset response between edges from stable observations after the edge.

checker: Drive 1ns after the falling edge of clk, and sample combinational outputs and the pre-handshake state after stabilization before the edge; after each rising edge, wait 1ns and for NBA and combinational propagation to settle before comparing the updated outputs. Assert asynchronous reset between two clock edges, wait 1ns to check the immediate response, then check the state after the next rising edge. Compare desc_ready every cycle; compare desc_result only after the edge of cycle 18/33 of a complete operation following reset and during subsequent idle; do not compare results while running. The independent input-history predictor maintains only inputs, previously stored state, and transaction counts; the monitor reads only actual ports; perform bitwise four-state comparisons of actual/expected and report UVM_ERROR on mismatches; count comparisons and output changes, report missing comparisons as errors as well, and do not generate expected from actual.

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-106-002

feature_ids: F-106-002

requirement_ids: R-N106-002

stimulus: After reset, issue single-cycle encryption and decryption requests separately and run for a fixed 18 or 33 cycles; check ready every cycle, including adjacent completion and next request and different idle intervals.

expected: In the idle state with desc_ready=1, assert only one of des_encipher_en or des_decipher_en for one sampling edge, called cycle 1; afterward, both remain 0 until completion. Hold data and key from before the request until completion. On cycle 1 following the request, ready becomes 0; on cycle 18 for encryption or cycle 33 for decryption, ready returns to 1 and the final result is provided simultaneously. In idle, ready remains 1. Simultaneous requests, requests while busy, or holding a request for multiple cycles are prohibited and are outside the legal domain.

checker: Drive 1ns after the falling edge of clk, and sample combinational outputs and the pre-handshake state after stabilization before the edge; after each rising edge, wait 1ns and for NBA and combinational propagation to settle before comparing the updated outputs. Assert asynchronous reset between two clock edges, wait 1ns to check the immediate response, then check the state after the next rising edge. Compare desc_ready every cycle; compare desc_result only after the edge of cycle 18/33 of a complete operation following reset and during subsequent idle; do not compare results while running. The independent input-history predictor maintains only inputs, previously stored state, and transaction counts; the monitor reads only actual ports; perform bitwise four-state comparisons of actual/expected and report UVM_ERROR on mismatches; count comparisons and output changes, report missing comparisons as errors as well, and do not generate expected from actual.

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-106-003

feature_ids: F-106-003

requirement_ids: R-N106-003

stimulus: Encrypt the standard known vector with a single-cycle request, then independently calculate standard DES for all-0, all-1, alternating-bit, single-bit, and at least 20 sets of full 64-bit random data/keys; compare after cycle 18.

expected: des_data and des_key_in are both 64 bits, with the most significant bit corresponding to standard DES bit 1. Encryption uses standard DES (FIPS 46-3), with a 64-bit initial permutation, 16 Feistel rounds, and inverse permutation; key PC1 removes the parity bit of each byte, and circular left shifts by 1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1 generate 16 PC2 subkeys. The input to the final inverse permutation is R16 concatenated with L16. The standard vector 0123456789ABCDEF with key 133457799BBCDFF1 produces 85E813540F0AB405.

checker: Drive 1ns after the falling edge of clk, and sample combinational outputs and the pre-handshake state after stabilization before the edge; after each rising edge, wait 1ns and for NBA and combinational propagation to settle before comparing the updated outputs. Assert asynchronous reset between two clock edges, wait 1ns to check the immediate response, then check the state after the next rising edge. Compare desc_ready every cycle; compare desc_result only after the edge of cycle 18/33 of a complete operation following reset and during subsequent idle; do not compare results while running. The independent input-history predictor maintains only inputs, previously stored state, and transaction counts; the monitor reads only actual ports; perform bitwise four-state comparisons of actual/expected and report UVM_ERROR on mismatches; count comparisons and output changes, report missing comparisons as errors as well, and do not generate expected from actual.

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-106-004

feature_ids: F-106-004

requirement_ids: R-N106-004

stimulus: Decrypt the standard vector and ciphertext generated by independent software encryption; perform complete operations separately for the same data with the baseline key and with the baseline key XOR 0101010101010101, checking the cycle-33 result and parity-bit invariance.

expected: Decryption uses the same DES data transformation but uses the 16 subkeys in reverse order; the standard ciphertext 85E813540F0AB405 decrypts to 0123456789ABCDEF using 133457799BBCDFF1. The least significant bit of each byte is a key parity bit and does not contribute to the result; changing these bits does not change the result for the same direction; no parity checking or error reporting is performed.

checker: Drive 1ns after the falling edge of clk, and sample combinational outputs and the pre-handshake state after stabilization before the edge; after each rising edge, wait 1ns and for NBA and combinational propagation to settle before comparing the updated outputs. Assert asynchronous reset between two clock edges, wait 1ns to check the immediate response, then check the state after the next rising edge. Compare desc_ready every cycle; compare desc_result only after the edge of cycle 18/33 of a complete operation following reset and during subsequent idle; do not compare results while running. The independent input-history predictor maintains only inputs, previously stored state, and transaction counts; the monitor reads only actual ports; perform bitwise four-state comparisons of actual/expected and report UVM_ERROR on mismatches; count comparisons and output changes, report missing comparisons as errors as well, and do not generate expected from actual.

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-106-005

feature_ids: F-106-005

requirement_ids: R-N106-005

stimulus: First encrypt, then change the idle data/key and wait multiple cycles to check that the result holds, then decrypt with a different key, then encrypt again; use an independent prediction each time, not the DUT result as the expected value.

expected: After completion, when no new operation has been started and no reset has occurred, desc_result holds its final value; changes to the input data or key while idle do not update this result. Each new legal request uses its own data and key; the direction, data, and key of previous transactions do not contaminate subsequent results.

checker: Drive 1ns after the falling edge of clk, and sample combinational outputs and the pre-handshake state after stabilization before the edge; after each rising edge, wait 1ns and for NBA and combinational propagation to settle before comparing the updated outputs. Assert asynchronous reset between two clock edges, wait 1ns to check the immediate response, then check the state after the next rising edge. Compare desc_ready every cycle; compare desc_result only after the edge of cycle 18/33 of a complete operation following reset and during subsequent idle; do not compare results while running. The independent input-history predictor maintains only inputs, previously stored state, and transaction counts; the monitor reads only actual ports; perform bitwise four-state comparisons of actual/expected and report UVM_ERROR on mismatches; count comparisons and output changes, report missing comparisons as errors as well, and do not generate expected from actual.

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv
