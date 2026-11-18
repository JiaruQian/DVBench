# fp32_sigmoid_pipeline Behavioral Specification

Covers only the native top level and fixed parameter combination declared in ports.md. All inputs satisfy the stability time at their sampling edges; no hidden hierarchical access.

### R-dv-062-001 — Per-cycle acceptance, order preservation, fixed latency, and bubbles

An independent FP32 input is accepted on each rising edge when valid_i=1 and both rst_i and clear_i are 0; there is no ready or backpressure. Data advances every cycle, valid preserves order, and bubbles appear only as valid_o=0 in the corresponding output cycles.

After an input is accepted on rising edge n, the output is valid after the NBA update on edge n+44.

Consecutive inputs and valid_i=0 bubbles of arbitrary length are allowed; result_o and invalid_o are constrained only when valid_o=1.

### R-dv-062-002 — Synchronous reset and clear flush in-flight valid markers

A rising edge on which rst_i or clear_i is high clears all in-flight valid markers; their logical OR takes priority over valid_i. The data and selection pipelines are not zeroed, so data in invalid cycles cannot be promised as reset values.

Assertion between edges imposes no asynchronous clearing obligation; valid_o is immediately 0 after an edge with reset/clear, and resumes with the fixed latency after acceptance restarts.

rst and clear each act independently; even if valid_i is simultaneously high, no input is accepted on that edge. Old data may still change during invalid output cycles.

### R-dv-062-003 — NaN canonicalization and priority

An input with either sign, any nonzero payload, and an all-1 exponent is a NaN; the output is the fixed canonical quiet NaN 0x7fc00000, and invalid_o is forced to 1, taking priority over the sign and input invalid.

Aligned with the corresponding input valid by the fixed latency; a flush cancels the token.

Cover positive and negative signs, quiet/signaling, and different payloads; the NaN output bit pattern is fixed, and comparing only isNaN is not allowed.

### R-dv-062-004 — Positive and negative infinity saturation and input invalid preservation

+Inf outputs 1.0 (3f800000), and -Inf outputs +0 (00000000); infinity itself does not force invalid, and the flag equals invalid_i for that token.

The same latency and flushing rules apply as for ordinary tokens.

Only an exponent of ff and a mantissa of 0 constitute Inf; the sign and NaN must be distinguished.

### R-dv-062-005 — Zeros, subnormals, and quantization of very small magnitudes

Both ±0 output 0.5 (3f000000). Finite magnitudes are first converted to Q5.16 for exponent fields 111..131; small magnitudes outside this range quantize to 0, so positive and negative subnormals and small normal numbers below the quantization resolution likewise output 0.5, with invalid preserved from the input.

Each input is quantized independently and then output after the fixed latency; bubbles do not change the numerical value.

Q5.16 conversion truncates rather than rounds; there is no rule forcing invalid for positive subnormals or directly saturating negative subnormals to 0.

### R-dv-062-006 — Fixed-point approximation in the finite domain and sign branches

For finite 0<|x|<=16, first truncate the magnitude to Q5.16, approximate exp(-magnitude), compute 1+e with RNE and the piecewise reciprocal q, and select q for positive inputs or e*q with RNE for negative inputs; see the numerical conventions for the piecewise and fixed-point rules.

The numerical value is aligned with the sign and invalid of that input by the fixed latency; back-to-back sign changes must not cause cross-talk.

Both exp and reciprocal use 16-segment linear interpolation with RNE. |x|=16 is within the domain, and saturation occurs only above 16; do not substitute the mathematical real-valued sigmoid for the fixed-point result.

### R-dv-062-007 — Strict saturation for large finite magnitudes

For finite |x|>16, exp returns 0, so positive inputs output 1.0 and negative inputs output +0, while the flag still preserves invalid_i.

The ordinary fixed latency applies, and valid is determined only by the acceptance history and flushing.

16 is the inclusive endpoint; large-magnitude saturation begins at 41800001/c1800001; the largest finite numbers are also legal inputs.

### R-dv-062-008 — Per-token invalid propagation and FTZ parameter profiles

Except that NaN forces invalid=1, legal finite inputs and Inf at the top level propagate invalid_i with the token; both FTZ=0/1 belong to this problem's profiles. FTZ controls only flushing of internal multiplication subnormal results to zero, whereas nonzero finite probabilities at this top level remain normal, so legal native inputs do not produce an expected numerical difference between profiles.

The flag must come from the same input token as the result and valid; it is checked only when valid_o=1.

The native ports do not include rounding_i; submodule RUP/RDN or standalone tiny products cannot be treated as obligations for this problem.


## Finite Numerical Conventions

The input is IEEE754 binary32. When the magnitude exponent is in 111..131, multiply the significand by 65536 and truncate toward zero to obtain the Q5.16 integer m; otherwise m=0. RNE means round-to-nearest-even. Compute r=RNE(m*94548/65536), taking the portion of r above the 16 fractional bits as the integer n, the top 4 fractional bits as the segment s, and the remaining 12 bits as the remainder u. The Q1.23 interpolated value for exp is A[s]-RNE((A[s]-A[s+1])*u/4096), then normalized to FP32 with scaling by 2^(-n); when the fractional part is 0, use exactly 2^(-n). Add e and 1 using FP32 RNE to obtain d. For the reciprocal, use the exponent of d to produce binary scaling, the top 4 mantissa bits to select the segment, and the following 12 bits to select the remainder, ignoring the lowest 7 mantissa bits; interpolate the reciprocal anchors using the same formula and then normalize. The positive branch takes q; the negative branch takes the FP32 product e*q with RNE, with FTZ controlling subnormal flushing to zero. The anchors are the following hexadecimal Q1.23 integers; replacing them with exact exp or division is not allowed.

|exp segment|high|low|
|---|---|---|
|0|800000|7a92bf|
|1|7a92bf|756063|
|2|756063|70666f|
|3|70666f|6ba27e|
|4|6ba27e|671246|
|5|671246|62b395|
|6|62b395|5e8452|
|7|5e8452|5a827a|
|8|5a827a|56ac1f|
|9|56ac1f|52ff6b|
|10|52ff6b|4f7a99|
|11|4f7a99|4c1bf8|
|12|4c1bf8|48e1ea|
|13|48e1ea|45cae1|
|14|45cae1|42d562|
|15|42d562|400000|

|reciprocal segment|high|low|
|---|---|---|
|0|800000|787878|
|1|787878|71c71c|
|2|71c71c|6bca1b|
|3|6bca1b|666666|
|4|666666|618618|
|5|618618|5d1746|
|6|5d1746|590b21|
|7|590b21|555555|
|8|555555|51eb85|
|9|51eb85|4ec4ec|
|10|4ec4ec|4bda13|
|11|4bda13|492492|
|12|492492|469ee6|
|13|469ee6|444444|
|14|444444|421084|
|15|421084|400000|

