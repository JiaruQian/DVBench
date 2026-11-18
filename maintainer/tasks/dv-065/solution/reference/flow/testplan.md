# Verification plan

## T-01

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Assert startup and midtraffic resets in bypass and conversion modes,including after a partly completed flush. Observe immediate output clearing and complete post-reset flush restart.

Expected: Reset immediately clears registered enable/address/data and status histories; the next released edges begin flush address0 again. No previous operation or pipeline transaction survives reset.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-02

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Enter operations using op_enable0-to1 and using done1-to0 while op_enable stays1. Use different scale,pad and conversion modes between operations,hold each configuration through traffic and draining,and vary unused precision/nan controls.

Expected: Each entry captures exactly the new configuration; done must prevent active state retention and permit subsequent entry. Continuous active operation uses its original captured values.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-03

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Sweep op_enable,cvt_enable and done independently over isolated and consecutive edges while operation pipelines are idle. Vary input precision,nan controls and payloads and inspect the full statistics outputs.

Expected: The third sampled enable history emerges exactly after three registers,including done1 cycles; both32-bit statistics stay zero.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-04

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Alternate direct,image and idle cycles with distinct full-width payloads and all address bits,including consecutive transactions and gap lengths0..8. Toggle all neutral info bits independently and check both bypass and converted transaction latency after flush.

Expected: Each transaction has its own unchanged17-bit address and aligned payload at exactly E+1 or E+5 for acceptance edgeE. Neither gaps nor source changes reorder transactions; unused info bits do not affect results.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-05

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Use all eight distinct byte and mean slices,signed/unsigned byte boundaries0,127,128,255,signed offset/mean extrema,and positive,zero and negative scales. Alternate mean selection independently of unsigned selection and compare complete64-bit outputs.

Expected: Each lane follows its own signed subtraction and multiplication without lane swapping; unsigned selection changes only byte extension and mean selection changes only the subtractand.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-06

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Cover shifts0,1,15,31,32,33,34,63,positive and negative half ties,values around each signed17/16/8 limit,and all four proc_precision codes. Construct products on both sides of rounding boundaries and compare every output byte at E+5.

Expected: All six shift bits matter; ties round away from zero and each saturation stage uses its stated signed bounds. Precision1 retains the low byte of the saturated16-bit result; other codes use saturated8-bit bytes.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-07

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Sweep all eight one-hot pad masks,alternating-bit masks and all-zero/all-one masks with distinct lane bytes and a distinct pad byte. Include bypass/conversion,direct-source masks and posttransaction idle gaps; inspect data/address every clock even when enable0.

Expected: Exactly the selected image bytes change to pad low8bits with correct latency. Direct transactions ignore padding and invalid-cycle native payloads retain their documented datapath/address relationships.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-08

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Observe every startup write address and completion boundary,then inject traffic during and after flush with distinct normal addresses. Reset after completion and during a second flush and verify restart and all native output payloads.

Expected: Exactly8192 sequential addresses0..8191 are written per reset without stalling; completion asserts on the last write and remains high. Flush address wins coincident data traffic and normal addressing resumes after completion.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.

## T-09

Stimulus: Tie all three native clocks together; use binary inputs stable around edges,asynchronous active-low reset,mutually exclusive source enables and info low nibble0001 for transactions. Drain12clocks before any configuration change and hold each captured configuration through its traffic. Repeat matched operation histories while perturbing each neutral field and every inactive-source payload. Establish distinct high address bits and unique lane/mean patterns,then compare complete native vectors over active,drain,idle and reset samples.

Expected: Only stated active domains change outputs. Inactive-source payloads and neutral fields create no writes or lane/address cross-coupling; all native widths remain observable.

Checker: Predict outputs in an independent input-only mathematical model of operation capture,abstract timed transaction histories,signed arithmetic,padding and flush index. Separate expected/actual wires feed exact four-state comparisons1ns after rising clock and reset assertion; each mismatch is UVM_ERROR with mandatory samples/resets and finite stimulus.
