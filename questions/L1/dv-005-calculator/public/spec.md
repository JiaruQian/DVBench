# exdbin_mac — Functional Specification, Revision 2.0

This revision defines a repaired 64-bit calculator. It supersedes revision 1's unresolved behavior; it is a functional revision, not a claim that the earlier implementation was correct.

### R-CALC-001 — Role and combinational behavior
The module is a stateless 64-bit adder/subtractor. It has no clock, reset, enable, handshake, stored operands or backpressure. Both outputs respond to the current inputs after combinational settling, independently of earlier inputs.

### R-CALC-002 — Native interface and bit order
Inputs are `alu_cmd[0:3]`, `fxu_areg_q[0:63]`, `fxu_breg_q[0:63]` and scalar `local_error_found`. Outputs are `bin_sum[0:63]` and scalar `bin_ovfl`. Index 0 is the most significant bit; index 63 is the least significant bit. Ports carry unsigned bit vectors; signed overflow interprets the same operand bits as two's-complement signed integers. There are no parameters.

### R-CALC-003 — Command selection
Command 0010 selects subtraction. Command 0001 selects addition. All other fully known 4-bit encodings are defined addition aliases with exactly the same data and overflow behavior as 0001. There is no invalid-command response or extra error output. Operand A always uses all 64 bits of `fxu_areg_q`.

### R-CALC-004 — Addition and carry
For every non-subtraction command, `bin_sum` is A plus the effective operand B defined in R-CALC-007, modulo 2^64. Carry propagates across every bit and byte boundary throughout the 64-bit word. Unsigned carry out is discarded; there is no saturation.

### R-CALC-005 — Subtraction and borrow
For command 0010, `bin_sum` is A minus the original B modulo 2^64. All 64 B bits participate at their corresponding positions, including index 11 independently of indices 0 and 1. This includes the two's-complement increment, so A minus A is zero and zero minus one is all ones. `local_error_found` has no effect on subtraction.

### R-CALC-006 — Signed overflow
`bin_ovfl` reports signed overflow of the complete 64-bit operation. Addition overflows when the two effective operands have equal signs and the wrapped result has the opposite sign. Subtraction overflows when original A and B have different signs and the wrapped result's sign differs from A. This is neither unsigned carry/borrow nor low-32-bit overflow. The flag is computed from the same effective operands as the result.

### R-CALC-007 — Local error injection
On addition and all addition aliases, `local_error_found=0` leaves B unchanged. When it is 1, effective B starts as the original B, then index 51 takes original B[50] and index 59 takes original B[58]. All other bits remain unchanged. These simultaneous replacements can affect subsequent arithmetic carry; they are not output bit flips. Index 50 has higher numeric weight than index 51, and likewise 58 versus 59. Subtraction bypasses both replacements regardless of the flag.

### R-CALC-008 — Outputs and observation window
Both outputs are meaningful for every fully known input combination once combinational propagation has settled. They have no valid signal and no required clock edge. No carry, borrow, zero-detect or internal debug signal is exposed. The result and overflow must belong to the same current operation.

### R-CALC-009 — Boundaries and wraparound
The full operand range is supported: zero, all ones, single set/clear bits, alternating patterns and both signed extrema. Carries and borrows cross the low/high 32-bit boundary. Equal operands subtract to zero; zero and all-one operands receive no special saturation or masking. Bit indices use the native ascending ranges throughout.

### R-CALC-010 — Four-state and input validity
Arithmetic is specified for known 0/1 operands and known command bits. Inputs may change independently; transient values before settling are not sampled. An X or Z `local_error_found` is irrelevant during subtraction and must not corrupt its defined outputs. For addition, if both affected source/destination pairs are equal known bits, the flag is likewise irrelevant, including X/Z. Otherwise an unknown flag, an unknown operand bit or an unknown command has no guaranteed numeric result; it must not be interpreted as a valid zero-valued operation. Once the inputs return to the defined domain, both outputs recover combinationally without reset.
