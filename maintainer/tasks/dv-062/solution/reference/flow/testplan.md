# Verification Plan

## T01

feature_ids: ["F01"]

requirement_ids: ["R-dv-062-001"]

stimulus: After reset is released, drive special/finite inputs back-to-back using s_spec/s_sweep, and interleave single-cycle and multi-cycle bubbles using s_gap and s_rand; driving follows the existing clocking block phase and does not wait for DUT output. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: valid_o equals the synchronous pipeline marker for valid_i accepted 44 edges earlier; every cycle that should produce an output has one corresponding result, with no extra results during idle or draining periods.

checker: The monitor samples actual valid and independent native model valid on every non-reset edge; the scoreboard performs exact four-state comparisons and also reports an error when expected is valid but actual is invalid; data is compared only when expected is valid, and the count must reach at least 1000 valid comparisons. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V01

source: sigmoid_pkg.sv::s_gap/body; sigmoid_pkg.sv::s_rand/body; sigmoid_pkg.sv::sig_monitor/run_phase; sigmoid_pkg.sv::sig_sb/write

## T02

feature_ids: ["F02"]

requirement_ids: ["R-dv-062-002"]

stimulus: s_clear applies clear after a continuous stream of finite numbers is already in flight and allows a full 60 cycles to drain before driving new data; s_rst pulses rst during a continuous stream and then resumes legal inputs; the initial rst spans at least two rising edges. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: Cleared old tokens are no longer valid; new tokens after resumption have normal ordering and latency; invalid result_o/invalid_o are not required to be 0.

checker: The independent model clears only the 45-bit tokens while continuing to predict data shifting; the scoreboard compares valid cycle by cycle and additionally compares data and the flag on legal valid cycles; the original interface's reset task does not force any internal signals. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V02

source: sigmoid_if.sv::pulse_reset; sigmoid_pkg.sv::s_clear/body; sigmoid_pkg.sv::s_rst/body; model/model.sv::dvbench_model.advance

## T03

feature_ids: ["F03"]

requirement_ids: ["R-dv-062-003"]

stimulus: s_spec drives 7fc00000, ffa00000, 7f800001, and ffffffff one by one, repeating each with invalid_i=0/1; full-bit-field LCG randomization supplements payloads. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: All valid NaN outputs are strictly 7fc00000, invalid_o=1.

checker: The native model generates canonical expectations from input classification; the scoreboard performs exact four-state comparisons of the bit pattern and flag without numerical tolerance. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V03

source: sigmoid_pkg.sv::s_spec/body; model/model.sv::dvbench_sigmoid_math.evaluate; sigmoid_pkg.sv::sig_sb/write

## T04

feature_ids: ["F04"]

requirement_ids: ["R-dv-062-004"]

stimulus: s_spec interleaves driving 7f800000 and ff800000, with invalid_i respectively 0/1, and mixes them back-to-back with NaN and normal numbers. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: Strictly compare +Inf→3f800000 and -Inf→00000000; the corresponding flag is preserved exactly.

checker: Classification of input history generates independent expectations; exact bit comparisons are performed in valid windows, with the two FTZ instances compared separately. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V04

source: sigmoid_pkg.sv::s_spec/body; model/model.sv::dvbench_sigmoid_math.evaluate; sigmoid_pkg.sv::sig_sb/write

## T05

feature_ids: ["F05"]

requirement_ids: ["R-dv-062-005"]

stimulus: s_spec drives ±0, the minimum/maximum positive and negative subnormals, and the minimum normal, and replays them with both invalid values; s_sweep covers small magnitudes such as b7f00000, 387fffff, b8f00000, and ba000000. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: When the Q5.16 magnitude m=0, the result is strictly 0.5 and invalid equals the input; nonzero m enters the finite approximate arithmetic rules.

checker: The native model quantizes according to the input fields; when the model outputs 0.5, the scoreboard compares exactly rather than masking this exact behavior with a general finite-value tolerance. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V05

source: sigmoid_pkg.sv::s_spec/body; sigmoid_pkg.sv::s_sweep/body; model/model.sv::dvbench_sigmoid_math.evaluate; sigmoid_pkg.sv::sig_sb/write

## T06

feature_ids: ["F06"]

requirement_ids: ["R-dv-062-006"]

stimulus: s_sweep performs directed sweeps of 96 points in the negative domain 0..16, 24 points in 0..1, and 128 points at k/8, while s_spec supplies points such as positive 1 and positive pi; s_rand mixes the actual run seed into the LCG starting point and samples 32-bit finite inputs; the numerical stream is resumed before and after bubbles, clear, and reset. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: The exact reference is the source RTL's fixed-point interpolation and rounding: exp quantization range=RNE(m*94548/65536), with linear interpolation between nearest-integer anchors of 2^(-k/16) in Q1.23 followed by RNE; the denominator is 1+e using FP32 RNE, and the reciprocal is interpolated from nearest-integer anchors of 1/(1+k/16) in Q1.23, followed by FP32 RNE multiplication in the negative branch. The same native model generates exact FP32 bit patterns using independent scalar integer operations, mathematically generated anchors audited for consistency, nearest-even exponent alignment, and 48-bit mantissa multiplication; valid outputs are bitwise equal, without using real-valued sigmoid or numerical tolerance.

checker: For each profile, the same self-contained model.sv consumes only native inputs and history to generate independent expected values aligned over 45 slots; the monitor samples actual/expected in stable valid windows, and the scoreboard reports errors using four-state inequality !== for valid, invalid, and all 32 bits of result. Compare valid every cycle to catch missing or extra outputs; D reuses the same file and exact comparisons. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V06

source: sigmoid_pkg.sv::s_sweep/body; sigmoid_pkg.sv::s_rand/body; model/model.sv::dvbench_sigmoid_math.evaluate; sigmoid_pkg.sv::sig_sb/write

## T07

feature_ids: ["F07"]

requirement_ids: ["R-dv-062-007"]

stimulus: s_spec drives c1800001, f0000000, df000000, and positive 7f7fffff, 7f000000, interleaving in-domain c1800000 and c17fffff; repeat each for invalid_i=0/1. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: Above the magnitude threshold, the output is strictly 00000000 or 3f800000, with invalid preserved exactly; out-of-domain inputs must not be classified as NaN or force invalid.

checker: Input bit-field comparisons generate saturation expectations; the scoreboard performs strict bit comparisons for 0 and 1 to prevent numerical tolerance from blurring the boundary. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V07

source: sigmoid_pkg.sv::s_spec/body; model/model.sv::dvbench_sigmoid_math.evaluate; sigmoid_pkg.sv::sig_sb/write

## T08

feature_ids: ["F08"]

requirement_ids: ["R-dv-062-008"]

stimulus: top instantiates native DUTs for FTZ=0/1 and independent models with the same parameters; s_spec crosses each input class with invalid=0/1, and s_rand further varies the input flag; each instance's own history is kept independent. Each scenario starts from a legal initial state in which rst is released after spanning at least two rising edges; the driver updates inputs in the clocking block output #1 window so that they are stable before the next accepting rising edge.

expected: Both profiles individually match the same mathematical probability relationship, exact token flag, and valid timing; comparison between the two DUTs is not used as the oracle; satellite coverage of submodules is not counted toward this problem.

checker: driver/monitor/scoreboard associates each profile with its own model expectations; invalid/valid are compared exactly; the value, valid, and invalid are all compared exactly bit by bit using four-state comparisons. Each input is accepted at the nth rising edge, and its corresponding result takes effect after the NBA at edge n+44; at rising edge n+45, before that edge's NBA updates, the monitor reads the actual and independent model outputs that were stable in the preceding cycle. Compare valid every cycle, and compare the 32-bit result and invalid exactly when expected_valid=1; an rst or clear sampling edge cancels in-flight tokens, and invalid data is not checked for zero.

implementation_id: V08

source: tb_top.sv::dut0/expected0; tb_top.sv::dut1/expected1; sigmoid_pkg.sv::s_spec/body; sigmoid_pkg.sv::sig_sb/write
