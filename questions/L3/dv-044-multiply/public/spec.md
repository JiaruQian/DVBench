# multiply black-box verification specification

The following natural-language contract defines behavior using native ports only. Parameter configurations are independent; transactions are not paired across configurations.

## Fixed parameter matrix

|Index|WIDTH_A|WIDTH_B|WIDTH_P|DROP_TOP_P|LATENCY|EN_SATURATE|EN_ROUND|SIGNED|
|---|---|---|---|---|---|---|---|---|
|0|16|16|31|1|3|0|0|1|
|1|16|16|31|1|0|0|0|1|
|2|16|16|31|1|4|0|0|1|
|3|16|16|16|1|3|0|1|1|
|4|16|16|16|1|3|1|0|1|
|5|16|16|16|1|1|1|1|1|
|6|16|16|32|0|2|0|0|0|
|7|8|12|20|0|1|0|0|1|
|8|16|16|31|1|3|0|1|1|
|9|16|16|31|1|3|1|1|1|

### R-MUL-001 — Streams, parameters, and legal domain

multiply has clk and synchronous active-high reset. Independent input streams A/B each have tdata,tlast,tvalid,tready. Output P has p_tdata,p_tlast,p_tvalid,p_tready. Data widths are WIDTH_A,WIDTH_B,WIDTH_P. Only the ten published configurations are required, including LATENCY=0/1/2/3/4, signed/unsigned, 8x12/16x16, rounding, clipping, and combinations. The native default WIDTH_P=32,DROP_TOP_P=1 gives an out-of-range slice and is excluded from the legal run domain. Configuration 0 is signed 16x16,P31,DROP1,LAT3 without rounding or saturation.

All state updates at rising clk edges. Inputs are established before the edge and held; ready=valid=1 at the same edge accepts a transfer. P data/last are meaningful when p_tvalid=1. Observe current handshakes and outputs in the settled pre-edge window, and next state after NBA/combinational settling. Inputs are two-state. An asserted, unaccepted input holds data/last/valid until acceptance or sampled reset. There is no asynchronous reset, force, or hierarchical access.

### R-MUL-002 — Synchronous reset and cancellation

A rising edge sampling reset=1 empties valid transactions from both input paths, the product path, and actually enabled round/clip buffers. After release, no pre-reset in-flight transaction may emerge. reset does not combinationally force ready low. Uninitialized pre-reset values are not observation evidence; invalid p_tdata/p_tlast during reset are unspecified. A reset pulse entirely between rising edges does not change valid-transaction state. Changing reset between edges does not clear state immediately; wait for its sampling edge and NBA/settling before checking reset. Old pre-edge valid is not a reset failure. Include startup and repeated in-flight resets, full/empty/stalled states, and new post-reset transactions for every enabled buffer.

### R-MUL-003 — Independent input buffering, ordered pairing, and last

A and B can be accepted and buffered independently. Pair their heads in their own acceptance order; a product transaction requires both valid heads. One valid side alone cannot produce valid P. The pair's last is a_tlast OR b_tlast, not AND. A/B need not arrive together. Backpressure cannot lose, duplicate, or reorder transactions. Reset cancels unpaired inputs on both sides. Consuming a pair additionally requires space in the subsequent product path. Each input ready depends on its own capacity, the opposite head's validity, and downstream capacity. Include A-leading/B-leading, prolonged single-side valid/invalid, all four last combinations, equal/unequal rhythms, and pairing after reset.

### R-MUL-004 — Stallable pipeline and exact handshake timing

The input-path stage count N is 1 for LATENCY=1/2 and 2 otherwise. The product-path stage count M is 1 for LATENCY=2/3 and 2 otherwise. LATENCY=0 still has N=2,M=2 control paths. Each stage stores one valid transaction. A stage can advance/capture upstream when its tail is accepted downstream or at least one position from that stage through the tail is empty. Input ready is the first stage's advance permission. Consuming either input tail also requires the opposite tail valid and the product first stage able to advance. Updates occur at rising edges with data/last/valid consistent with their transactions. LATENCY's name does not guarantee that every configuration's unstalled first-output delay equals that value: base control takes N+M sampled edges, plus actually enabled registered conversion stages.

ready can respond combinationally to output backpressure or internal vacancies. Check ready/valid every edge under full state, partial holes, and release; compare P only in its valid domain. Include all LATENCY values, complete occupancy, local bubbles, long stalls, single-cycle ready pulses, and resumed throughput.

### R-MUL-005 — Multiplication, signedness, widths, and LATENCY=0

SIGNED=1 interprets A/B as two's-complement values at their own widths; SIGNED=0 multiplies unsigned values. Full product width is W=WIDTH_A+WIDTH_B. For nonzero LATENCY, product data belongs to the ordered pair of buffered inputs. LATENCY=0 has a fixed special behavior: its data source is the combinational product of current native a_tdata/b_tdata, while valid/last/ready still pass through N=2,M=2 control paths. Its data need not match the paired historical transaction and need not hold its original value during output backpressure. Model this case separately rather than assuming an ideal zero-latency AXI multiplier.

For LATENCY=0 compute from current A/B in every settled observation window; other configurations use accepted/paired history. Interpret signs at complete native widths before slicing. Include 0,+/-1, minimum negative, maximum positive, all ones, asymmetric widths, unsigned top-bit values, and current inputs differing from buffered history.

### R-MUL-006 — Output slicing without conversion

With EN_SATURATE=0 and EN_ROUND=0, drop the top DROP_TOP_P bits of the W-bit product, leaving D=W-DROP_TOP_P bits. Keep the high WIDTH_P bits of those D bits, discarding D-WIDTH_P low bits without rounding or saturation. last/valid come directly from base control, and p_tready feeds back directly to it. This branch adds no output register stage. Valid observations and the LATENCY=0 case follow the preceding rules. Include DROP_TOP_P=0/1, WIDTH_P=D, narrower P, and high/low truncation for positive and negative products.

### R-MUL-007 — Rounding alone and safe positive bound

With rounding enabled alone, first drop DROP_TOP_P high bits to obtain a D-bit value, then remove K=D-WIDTH_P low bits. K=0 passes through without a buffer. For K>0, add bit K-1 to the high WIDTH_P bits for nearest rounding, with ties toward positive infinity. If K>1 and those high bits encode the maximum positive value, suppress the increment to avoid wrapping positive to negative. Otherwise truncate modulo WIDTH_P bits. K>0 uses a one-entry registered output buffer whose ready means empty or downstream ready; valid/data/last are stored with the transaction.

Actual rounding adds one register stage, while equal widths add neither latency nor capacity. Include round bit 0/1, positive/negative ties, safe-bound suppression, and WIDTH_IN=WIDTH_OUT pass-through.

### R-MUL-008 — Saturation alone and subsequent slicing

With saturation enabled alone, saturate the complete W-bit product as signed two's complement into the D=W-DROP_TOP_P range [-2^(D-1),2^(D-1)-1], then take the high WIDTH_P bits of that D-bit value without rounding. Saturation interprets the bits as signed even though SIGNED controls the earlier multiplication. D=W passes through; otherwise saturation adds a one-entry registered buffer. Its ready means empty or downstream able to accept. Data is specified only when valid. Include maximum positive products, positive overflow from squaring minimum negative, negative/non-overflow cases, high-bit slicing after saturation, last, and backpressure.

### R-MUL-009 — Combined rounding/saturation and two-entry buffers

When both enables are one, sign-extend the full product by one bit if DROP_TOP_P is nonzero. Intermediate width I=WIDTH_P+DROP_TOP_P+1; if DROP_TOP_P=0, I=WIDTH_P and there is no extension. When W=WIDTH_P+DROP_TOP_P the rounding stage passes through; otherwise round to nearest at width I. The safe positive-bound suppression is disabled for nonzero DROP_TOP_P and enabled for DROP_TOP_P=0. Next saturate as signed to WIDTH_P; if DROP_TOP_P=0 this saturation stage passes through. Each actually enabled stage uses a two-entry buffer with registered output: input_ready=1 at occupancy 0 or 1 and 0 at occupancy 2, even when downstream removes an item at that full-state edge. A non-full buffer may pop an old item and accept a new item together. Empty queues do not pass through combinationally.

Each enabled conversion stage adds at least one sampled-edge delay. A full two-entry buffer's ready does not combinationally follow p_tready. Pass-through stages add no buffer. Include both conversions enabled, round bypass plus clipping, occupancies 0/1/2, full-state pop, positive/negative ties, and saturation bounds.
