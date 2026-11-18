## F1

requirement_ids: R-bb12edf1-001

module: fpnew_fma

definition: A=operands_i[0], B=operands_i[1], C=operands_i[2], all binary32. op_i=0(FMADD) computes A*B+C, 1(FNMSUB) computes -A*B+C, 2(ADD) computes B+C, and 3(MUL) computes A*B; op_mod_i inverts the sign of C in the first three operations, and MUL ignores it. ADD completely ignores A and its boxed state, and MUL completely ignores C and its boxed state. Finite multiply-add performs exact multiplication and addition first, then rounds only once.

interface: operands_i、is_boxed_i、op_i、op_mod_i、result_o

timing: Zero-register configuration: observe in the combinational settling window after input changes, with no cycle-by-cycle latency; compare data only when valid is asserted, and always compare control and extension.

boundary: Legal op values are 0..3; arithmetic results for other encodings are unspecified. This applies to positive and negative values and cancellation; rounding the intermediate product first is not allowed.

## F2

requirement_ids: R-bb12edf1-002

module: fpnew_fma

definition: rnd_mode_i=0 is round to nearest, ties to even RNE, 1 is round toward zero RTZ, 2 is round toward negative infinity RDN, 3 is round toward positive infinity RUP, 4 is round to nearest, ties away from zero RMM, and 5 is ROD, which truncates and then sets the least significant bit of an inexact result to make it odd. Exact results do not change with the rounding mode. When effective addition of opposite signs cancels exactly to zero, RDN returns -0 and the other modes return +0; same-sign zeros retain their sign. The zero addend for MUL is +0 under RDN and -0 under the other modes, after which the rules above determine the zero sign.

interface: operands_i、rnd_mode_i、op_i、op_mod_i、result_o

timing: Zero-register configuration: observe in the combinational settling window after input changes, with no cycle-by-cycle latency; compare data only when valid is asserted, and always compare control and extension.

boundary: Numerical values for modes 6/7 are unspecified. Includes both sides of a midpoint, retained-bit parity, signs, and rounding carry.

## F3

requirement_ids: R-bb12edf1-003

module: fpnew_fma

definition: Used operands are classified by sign, 8-bit exponent, and 23-bit fraction as normal, subnormal, zero, infinity, quiet NaN, or signalling NaN. When the corresponding bit of is_boxed_i is 0, the operand is treated as quiet NaN, and its bit pattern is not treated as sNaN or infinity. Operands ignored by ADD/MUL do not affect classification results.

interface: operands_i、is_boxed_i、op_i、result_o、status_o

timing: Zero-register configuration: observe in the combinational settling window after input changes, with no cycle-by-cycle latency; compare data only when valid is asserted, and always compare control and extension.

boundary: An all-1 exponent and nonzero fraction indicate NaN; a most significant fraction bit of 0 indicates sNaN, and 1 indicates qNaN; an exponent of 0 and nonzero fraction indicate subnormal, with gradual underflow and no flushing to zero.

## F4

requirement_ids: R-bb12edf1-004

module: fpnew_fma

definition: When the used A/B form infinity*zero or zero*infinity, return canonical qNaN 0x7fc00000 with NV=1, even if the addend is qNaN. Otherwise, if any used operand is NaN, return this canonical qNaN, with NV determined only by used sNaNs. Otherwise, adding an infinite product to an infinite addend of the opposite effective sign returns canonical qNaN with NV=1; other infinite results use the effective sign of the product or addend, with NV=0. DZ/OF/UF/NX are all 0 on the special path.

interface: operands_i、is_boxed_i、op_i、op_mod_i、result_o、status_o

timing: Zero-register configuration: observe in the combinational settling window after input changes, with no cycle-by-cycle latency; compare data only when valid is asserted, and always compare control and extension.

boundary: Classification and signs are based on the effective operation after op and mod adjustments; NaNs do not propagate payloads and always use the positive canonical encoding.

## F5

requirement_ids: R-bb12edf1-005

module: fpnew_fma

definition: status_o[4:0]={NV,DZ,OF,UF,NX}. On the ordinary finite path, NV=DZ=0; discarding nonzero precision or overflow sets NX=1. Exceeding the finite exponent range or a rounding carry to infinity sets OF=1, and OF always accompanies NX; the result is selected as the maximum finite value or infinity according to the rounding direction. UF is 1 only when NX=1 and the result is tiny; exact subnormals do not set UF. tiny is determined by whether the exact result, rounded to 24-bit significand precision with an unbounded exponent, is below the minimum normal; UF=1 is still possible when the final encoding is the minimum normal.

interface: operands_i、rnd_mode_i、op_i、result_o、status_o

timing: Zero-register configuration: observe in the combinational settling window after input changes, with no cycle-by-cycle latency; compare data only when valid is asserted, and always compare control and extension.

boundary: Minimum normal=2^-126, subnormal step=2^-149. Near the minimum normal, the tiny boundary distance for RNE/RMM is 1/4 of a subnormal step, and only distances greater than this value are tiny; when directed rounding produces the minimum normal, the distance must reach 1/2 of a step to be tiny. The final exponent alone must not be used.

## F6

requirement_ids: R-bb12edf1-006

module: fpnew_fma

definition: Fixed NumPipeRegs=0: in_ready_o combinationally equals out_ready_i, and out_valid_o and busy_o combinationally equal in_valid_i. There is no clock-cycle latency; observe in the combinational settling window in the same cycle after inputs stabilize. When out_valid_o=1, result/status/tag/mask/aux are valid regardless of out_ready_i; a transfer occurs only when valid and ready are both 1. Numerical data is not required when out_valid_o=0. extension_bit_o is always 1.

interface: in_valid_i、out_ready_i、in_ready_o、out_valid_o、busy_o、extension_bit_o、result_o、status_o

timing: Zero-register configuration: observe in the combinational settling window after input changes, with no cycle-by-cycle latency; compare data only when valid is asserted, and always compare control and extension.

boundary: This configuration does not store transactions; ready=0 does not buffer the output, and the output still changes combinationally when inputs change. A normal upstream source holds the valid request and data stable across sampling edges during backpressure.

## F7

requirement_ids: R-bb12edf1-007

module: fpnew_fma

definition: tag_o=tag_i, mask_o=mask_i, aux_o=aux_i, all one bit. mask_i=0 does not suppress arithmetic or valid. The zero-register configuration has no resettable state; rst_ni, flush_i, and reg_ena_i do not change combinational computation, handshaking, or sidebands; reset or flush must not be assumed to force out_valid_o=0. The clock introduces no state.

interface: clk_i、rst_ni、flush_i、reg_ena_i、tag_i、tag_o、mask_i、mask_o、aux_i、aux_o、in_valid_i、out_valid_o

timing: Zero-register configuration: observe in the combinational settling window after input changes, with no cycle-by-cycle latency; compare data only when valid is asserted, and always compare control and extension.

boundary: Initialization first asserts reset low and then releases it. rst_ni is the native active-low asynchronous register reset control, but the fixed configuration instantiates no pipeline registers. For invalid data, compare only the handshake and extension.

## F8

requirement_ids: R-bb12edf1-008

module: fpnew_fma

definition: This task verifies both the native zero-stage and two-stage distributed pipeline configurations of the complete fpnew_fma. original_comb: FP32, NumPipeRegs=0, BEFORE, TagType=logic[3:0], AuxType=logic[1:0]; original_pipe2: FP32, NumPipeRegs=2, DISTRIBUTED, with the same 4-bit tag and 2-bit aux. default_logic is the native default zero-stage configuration with one-bit sidebands. The combinational control conclusions in zero-stage R6/R7 apply only to zero stages; input data in the two-stage configuration is accepted on a rising edge and appears at the output after two advances, allowing throughput of one item per cycle. In the two stages, a stage can advance when valid is a bubble, and holds when valid and downstream is not ready; in_ready is derived recursively from each stage being empty or downstream being ready. busy equals input valid OR the valid of any storage stage; extension is always 1. The two-stage configuration has a source-RTL-specific boundary: when the final finite result is inexact and encodes exactly as the minimum normal, if the distance by which the exact absolute value is below the minimum normal is strictly between 1/4 and 1/2 of a subnormal step, UF depends on whether the external rnd_mode_i at that time is RNE or RMM, rather than on the rm saved for that transaction; when the distance reaches 1/2 of a step, UF=1, and when the distance is no greater than 1/4 of a step, UF=0. For other results, the value and flags are still determined by the transaction's rm. This boundary is observed in the stable window of the intermediate computation output; this two-stage configuration has no output register.

interface: clk_i、rst_ni、operands_i、rnd_mode_i、tag_i、tag_o、aux_i、aux_o、mask_i、mask_o、in_valid_i、in_ready_o、out_valid_o、out_ready_i、busy_o、extension_bit_o、flush_i、reg_ena_i

timing: Inputs are accepted on rising edges; outputs are observed in the combinational settling window after the edge and the settling window after asynchronous reset; latency is calculated according to actual two-stage advancement and backpressure.

boundary: Each two-stage configuration has one input register stage and one intermediate register stage. A falling edge of rst_ni asynchronously clears all stored valid bits and data; flush_i clears all stored valid bits with priority on the rising edge but does not clear data, and does not remove the contribution of combinational input valid to busy. Data registers update when ready and the source is valid; reg_ena_i[0]/[1] additionally force data updates in the corresponding stages without changing the valid handshake. tag/mask/aux propagate with the corresponding data under the same enables; mask does not suppress computation. Under backpressure and without an external override, valid data in the last stage holds. Compare data only when valid is asserted; items canceled after reset/flush must not be treated as new transactions.
