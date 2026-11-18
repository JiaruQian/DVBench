# Verification plan

## T-01

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Fill pending and active data in every bank, stall outputs, assert reset between edges, and inspect immediately after settling. Reinitialize distinct banks and flush each one while simultaneously attempting enqueue, head loading or retirement; also toggle flush between edges without a rising edge.

Expected: Reset immediately zeros all state and outputs; a flush only clears its selected bank at its edge and wins all simultaneous operations there. Other banks retain or advance according to their own inputs.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.

## T-02

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Enqueue distinct lane records into all banks, using different lane0/lane1 wid values and every mask. Sweep each field through zero, all-one, one-hot and distinct lane patterns. Repeat otherwise identical histories with only writemask changed and with arbitrary inconsistent instruction encodings.

Expected: Only lane0 wid selects the bank, all exported metadata remains bit-exact in its lane and bank slice, lane1 wid never reroutes, and writemask/opaque opcode choices cannot alter control behavior.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.

## T-03

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Hold downstream blocked and send at least three pairs to each bank; inspect both ready outputs and perturb rejected inputs. Then release downstream while full and keep input valid, observing rejection on the first head-loading edge and acceptance only once pre-edge occupancy is below two. Exercise simultaneous load/enqueue from occupancy one.

Expected: Ready depends on pre-edge pending occupancy and selected lane0 bank only. Capacity is two pending plus one active pair; rejected data never appears. Simultaneous operations preserve precise FIFO order without a full-queue acceptance bypass.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.

## T-04

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Start with empty queue/active state and enqueue while both downstream inputs are one; track the first possible active edge. Independently hold each readiness input low with queued work, then release it with grant low. Include zero-mask pairs before nonzero pairs and grant toggles while active is empty.

Expected: Only the conjunction of the two readiness inputs permits a registered head load; grant is irrelevant to loading. Enqueued data has no same-edge bypass, and zero-mask payloads load and progress according to the same registered rule.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.

## T-05

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Load every mask0..3 using distinguishable lane payloads into every bank. Stall with each downstream-ready combination and grant low/high, inspect all fields before and after retiring a lane. Keep several banks valid simultaneously.

Expected: Valid follows active eligibility only; lane selection is lowest set bit and remains stable during a stall. Every field uses the same selected lane, and simultaneous banks preserve fixed output slice order.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.

## T-06

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Run masks1,2,3 with continuous queued traffic and continuous grant/ready, recording each lane and gap. Independently suppress grant, issue-ready or warp-ready on the would-be retirement edge, and enqueue new data concurrently. Repeat around flush and reset boundaries.

Expected: Only fully granted/ready valid lanes retire. Pair order and lane order remain exact; the final retirement edge leaves active invalid and the next pair loads on a later edge, with no same-edge replacement.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.

## T-07

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Load distinct lane0/lane1 payloads, retire the last eligible lane and inspect every invalid output field. Perturb all request fields during empty and full rejected cycles, load zero-mask pairs, and then flush/reset.

Expected: Invalid outputs hold/select the documented retained lane0 data rather than being unconstrained or forced zero. Only head loading, flush and reset can change the active payload snapshot.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.

## T-08

Stimulus: Use fixed parameters159/2/2,eight banks and known binary inputs stable around rising edges. Establish pair/active state only through accepted enqueue and ready-gated head loads after asynchronous reset. Build distinct active/queued histories in all eight banks, then vary all eight ready/grant bits independently. Simultaneously load/retire multiple banks, route input to another bank and flush a third. Compare complete ready,valid and payload vectors after every edge.

Expected: Only each bank own accepted history and control bits affect its state, while permitted concurrent operations occur together. No cross-bank payload, ready,valid or flush contamination occurs.

Checker: An independent input-only abstract queue and lane-eligibility model predicts every native output. Separate actual/predicted wires feed four-state comparisons1ns after rising clk and asynchronous reset. No DUT output or hierarchy enters prediction; any mismatch reports UVM_ERROR, with finite stimulus and mandatory sample/reset counts.
