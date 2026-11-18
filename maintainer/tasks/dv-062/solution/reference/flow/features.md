# Functional Description

## F01

requirement_ids：R-dv-062-001
module：fp32_sigmoid_pipeline
definition: An independent FP32 input is accepted on each rising edge when valid_i=1 and rst_i and clear_i are both 0; there is no ready or backpressure. Data advances every cycle, valid preserves ordering, and bubbles manifest only as valid_o=0 in the corresponding output cycle.
interface：clk_i、rst_i、clear_i、valid_i、data_i、invalid_i、valid_o、result_o、invalid_o
timing: After an input is accepted on rising edge n, the output is valid after the NBA update on edge n+44; a pre-edge monitor reads it on edge n+45.
boundary: Consecutive inputs and valid_i=0 bubbles of arbitrary length are allowed; result_o and invalid_o are constrained only when valid_o=1.
parent_id：None

## F02

requirement_ids：R-dv-062-002
module：fp32_sigmoid_pipeline
definition: A rising edge on which rst_i or clear_i is high clears all in-flight valid bits; the logical OR of the two takes priority over valid_i. The data and selection pipelines are not cleared, so data during invalid cycles cannot be promised as reset values.
interface：clk_i、rst_i、clear_i、valid_i、valid_o、result_o、invalid_o
timing: Assertion between edges imposes no asynchronous clearing obligation; valid_o is immediately 0 after an edge on which reset/clear occurs, and resumes with the fixed latency after acceptance restarts.
boundary: rst and clear act independently; even if valid_i is high at the same time, no input is accepted on that edge. Old data may still change during invalid output cycles.
parent_id：None

## F03

requirement_ids：R-dv-062-003
module：fp32_sigmoid_pipeline
definition: Inputs with either sign, any nonzero payload, and an all-ones exponent are NaNs; the output is the fixed canonical quiet NaN 0x7fc00000, and invalid_o is forced to 1, with priority over the sign and input invalid.
interface：data_i、invalid_i、valid_i、valid_o、result_o、invalid_o
timing: Aligned with the corresponding input valid at a fixed latency; flushing cancels tokens.
boundary: Cover both signs, quiet/signaling, and different payloads; the NaN output bit pattern is fixed, and comparing only isNaN is not allowed.
parent_id：None

## F04

requirement_ids：R-dv-062-004
module：fp32_sigmoid_pipeline
definition: +Inf outputs 1.0(3f800000), and -Inf outputs +0(00000000); infinity itself does not force invalid, and the flag equals invalid_i of that token.
interface：data_i、invalid_i、valid_i、valid_o、result_o、invalid_o
timing: The same latency and flushing rules as ordinary tokens.
boundary: Only an exponent of ff and a zero mantissa constitute Inf; the sign and NaN must be distinguished.
parent_id：None

## F05

requirement_ids：R-dv-062-005
module：fp32_sigmoid_pipeline
definition: Both ±0 output 0.5(3f000000). Finite magnitudes are first converted to Q5.16 according to exponent field 111..131; small magnitudes outside the domain have a quantized value of 0, so positive and negative subnormals and small normal numbers below the quantization resolution likewise output 0.5, with invalid inherited from the input.
interface：data_i、invalid_i、valid_i、valid_o、result_o、invalid_o
timing: Each input is quantized independently and then output at the fixed latency; bubbles do not change the value.
boundary: Q5.16 conversion truncates rather than rounds; there is no rule that forces invalid for positive subnormals or directly saturates negative subnormals to 0.
parent_id：None

## F06

requirement_ids：R-dv-062-006
module：fp32_sigmoid_pipeline
definition: For 0<|x|<=16, the fixed implementation uses the quantized negative magnitude for an exp approximation, then computes 1+exp and an approximate reciprocal; positive inputs select the reciprocal, and negative inputs select exp multiplied by the reciprocal. The numerical contract is governed by the fixed-point/LUT and RNE behavior of the hidden source RTL; it does not claim an exact real-valued sigmoid or any unproven ULP bound.
interface：data_i、invalid_i、valid_i、valid_o、result_o、invalid_o
timing: The value is aligned with that input's sign and invalid along the fixed latency; back-to-back sign changes must not cause crosstalk.
boundary: Magnitude is truncated according to Q5.16; exp and reciprocal both use 16-segment interpolation; multiplication in the normal negative branch uses RNE. |x|=16 is still in-domain, and saturation occurs only above 16.
parent_id：None

## F07

requirement_ids：R-dv-062-007
module：fp32_sigmoid_pipeline
definition: For finite |x|>16, exp returns 0, so positive inputs output 1.0 and negative inputs output +0, with the flag still inherited from invalid_i.
interface：data_i、invalid_i、valid_i、valid_o、result_o、invalid_o
timing: The same ordinary fixed latency; valid is determined only by acceptance history and flushing.
boundary: 16 is the endpoint of a closed interval; large-magnitude saturation begins at 41800001/c1800001; the maximum finite number is also a legal input.
parent_id：None

## F08

requirement_ids：R-dv-062-008
module：fp32_sigmoid_pipeline
definition: Except that NaN forces invalid=1, legal finite inputs and Inf at the top level propagate invalid_i with the token; both FTZ=0/1 belong to this problem's profiles. FTZ controls only flushing internal multiplication subnormal results to zero, while nonzero finite probabilities at this top level remain normal, so legal native inputs do not produce an expected numerical difference between profiles.
interface：clk_i、rst_i、clear_i、valid_i、data_i、invalid_i、valid_o、result_o、invalid_o
timing: The flag must come from the same input token as the result and valid; it is checked only when valid_o=1.
boundary: The native ports do not include rounding_i; submodule RUP/RDN or independent tiny products cannot be treated as obligations of this problem.
parent_id：None
