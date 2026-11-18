# testplan

### T-CALC-1

test_id: T-CALC-1

feature_ids: F-CALC-001, F-CALC-002, F-CALC-008

requirement_ids: R-CALC-001, R-CALC-002, R-CALC-008

stimulus: No DUT initialization is needed. Drive successive operations, changing command, A, B and flag independently and in combination; repeat the same operation after different predecessors; use low and high bits. Wait for settling and compare both outputs each time.

expected: Stateless combinational behavior, ascending native indices, current result and overflow without reset/handshake or artificial cycle latency. Independently prepare effective B from inputs and use signed 65-bit A+B_eff or A-B. bin_sum is bits 63:0 and bin_ovfl is wide[64] xor wide[63]. Compare after settling for every driven vector.

checker: A native-port monitor sends actual outputs and input-only dvbench_model predictions to native_scoreboard. Four-state case inequality reports UVM_ERROR on mismatch; require comparison counts and output activity. No DUT output is used as expected.

implementation_id: native_sequence.body/native_scoreboard.write

source: tb.sv

### T-CALC-2

test_id: T-CALC-2

feature_ids: F-CALC-004, F-CALC-005, F-CALC-009

requirement_ids: R-CALC-004, R-CALC-005, R-CALC-009

stimulus: No DUT initialization is needed. Apply addition and subtraction with zero, one, all ones, equal operands, walking ones/zeros, alternating words, signed extrema, carry/borrow across bit/byte/32-bit boundaries, and B[11] independent of B[0]/B[1]; use both flag values and compare both outputs.

expected: A plus effective B or A minus original B modulo 2^64. No saturation, truncation at 32 bits, or wrong-index complement. Independently prepare effective B from inputs and use signed 65-bit A+B_eff or A-B. bin_sum is bits 63:0 and bin_ovfl is wide[64] xor wide[63]. Compare after settling for every driven vector.

checker: A native-port monitor sends actual outputs and input-only dvbench_model predictions to native_scoreboard. Four-state case inequality reports UVM_ERROR on mismatch; require comparison counts and output activity. No DUT output is used as expected.

implementation_id: native_sequence.body/native_scoreboard.write

source: tb.sv

### T-CALC-3

test_id: T-CALC-3

feature_ids: F-CALC-006

requirement_ids: R-CALC-006

stimulus: No DUT initialization is needed. Compare positive and negative signed overflow and nonoverflow for add/sub: MAX+1, MIN+(-1), MIN-1, MAX-(-1), ordinary same/opposite sign cases; compare low32 overflow without full64 overflow and unsigned carry without signed overflow. Include error injection.

expected: Overflow is full 64-bit signed overflow computed from the same effective operands and final result, including subtraction increment. Independently prepare effective B from inputs and use signed 65-bit A+B_eff or A-B. bin_sum is bits 63:0 and bin_ovfl is wide[64] xor wide[63]. Compare after settling for every driven vector.

checker: A native-port monitor sends actual outputs and input-only dvbench_model predictions to native_scoreboard. Four-state case inequality reports UVM_ERROR on mismatch; require comparison counts and output activity. No DUT output is used as expected.

implementation_id: native_sequence.body/native_scoreboard.write

source: tb.sv

### T-CALC-4

test_id: T-CALC-4

feature_ids: F-CALC-007, F-CALC-005

requirement_ids: R-CALC-007, R-CALC-005

stimulus: No DUT initialization is needed. Independently vary original B[50:51] and B[58:59] through equal and unequal pairs, toggle flag 0/1, compare add and subtract and addition aliases. Include carries from replacement positions.

expected: Flag 1 replaces effective B[51] with original B[50] and B[59] with original B[58] only for addition; flag 0 and every subtraction preserve original B. Overflow uses the same effective word. Independently prepare effective B from inputs and use signed 65-bit A+B_eff or A-B. bin_sum is bits 63:0 and bin_ovfl is wide[64] xor wide[63]. Compare after settling for every driven vector.

checker: A native-port monitor sends actual outputs and input-only dvbench_model predictions to native_scoreboard. Four-state case inequality reports UVM_ERROR on mismatch; require comparison counts and output activity. No DUT output is used as expected.

implementation_id: native_sequence.body/native_scoreboard.write

source: tb.sv

### T-CALC-5

test_id: T-CALC-5

feature_ids: F-CALC-003

requirement_ids: R-CALC-003

stimulus: No DUT initialization is needed. Exercise every one of the 16 known command encodings, both flags and nonzero data in all word regions including indices 32:47; compare both outputs after each change.

expected: 0010 subtracts. All other encodings have precisely the addition and active-high injection behavior; no zeroed segment or invalid response. Independently prepare effective B from inputs and use signed 65-bit A+B_eff or A-B. bin_sum is bits 63:0 and bin_ovfl is wide[64] xor wide[63]. Compare after settling for every driven vector.

checker: A native-port monitor sends actual outputs and input-only dvbench_model predictions to native_scoreboard. Four-state case inequality reports UVM_ERROR on mismatch; require comparison counts and output activity. No DUT output is used as expected.

implementation_id: native_sequence.body/native_scoreboard.write

source: tb.sv

### T-CALC-6

test_id: T-CALC-6

feature_ids: F-CALC-010

requirement_ids: R-CALC-010

stimulus: No DUT initialization is needed. Compare subtraction with known command/operands and flag X then Z. Compare addition with equal known B[50]=B[51] and B[58]=B[59] and flag X/Z. Return to known flag and operands and compare recovery.

expected: Irrelevant X/Z flag does not corrupt defined outputs; recovery is combinational. No exact numeric expectation for other unspecified X/Z input combinations. Independently prepare effective B from inputs and use signed 65-bit A+B_eff or A-B. bin_sum is bits 63:0 and bin_ovfl is wide[64] xor wide[63]. Compare after settling for every driven vector.

checker: A native-port monitor sends actual outputs and input-only dvbench_model predictions to native_scoreboard. Four-state case inequality reports UVM_ERROR on mismatch; require comparison counts and output activity. No DUT output is used as expected.

implementation_id: native_sequence.body/native_scoreboard.write

source: tb.sv
