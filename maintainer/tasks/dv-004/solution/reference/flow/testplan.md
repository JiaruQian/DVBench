# Reference testplan

{
  "test_id": "T1",
  "feature_ids": [
    "F1"
  ],
  "requirement_ids": [
    "R-p8-tlff-001"
  ],
  "stimulus": "Begin with reset high across a rising edge, then drive the following phases. On pair 0 A vary all native fields and both valid/ready bits independently during reset, including zero, all ones and seeded full-width patterns. Then after a reset edge issue legal PutFull, PutPartial, Arithmetic, Logical, Get and Hint requests over sizes 0 through 5, respecting masks, operation limits and multibeat histories; exercise every pair-zero source with a matched Get response.",
  "expected": "For pair 0 A, auto_out_0_a_valid and every auto_out_0_a_bits field equal the corresponding auto_in_0_a input. auto_in_0_a_ready equals auto_out_0_a_ready independently of valid. Every native opcode, param, size, source, address, mask, data and corrupt bit is preserved.",
  "checker": "The self-contained independent dvbench_model computes expected native values from submitted input signals alone. tlff_scoreboard compares every actual native output to a separate expected signal using four-state inequality two time units after falling and rising edges. Report UVM_ERROR for mismatch, count observations and reject fewer than 100 samples. Do not mask invalid, reset or stalled values. No DUT output feeds expected values.",
  "implementation_id": "tlff_scoreboard.compare",
  "source": "tlff_pkg.sv:tlff_sequence.body; tlff_scoreboard.compare"
}

{
  "test_id": "T2",
  "feature_ids": [
    "F2"
  ],
  "requirement_ids": [
    "R-p8-tlff-002"
  ],
  "stimulus": "Begin with reset high across a rising edge, then drive the following phases. On pair 0 D vary every native response field and valid/ready independently during reset. After a reset edge, issue legal requests then matching AccessAck, AccessAckData and HintAck responses with the correct source, size and beat count, including every source. Never introduce a first response without an outstanding request.",
  "expected": "For pair 0 D, auto_in_0_d_valid and every auto_in_0_d_bits field equal the corresponding auto_out_0_d input. auto_out_0_d_ready equals auto_in_0_d_ready independently of valid. Every native opcode, param, size, source, sink, denied, data and corrupt bit is preserved.",
  "checker": "The self-contained independent dvbench_model computes expected native values from submitted input signals alone. tlff_scoreboard compares every actual native output to a separate expected signal using four-state inequality two time units after falling and rising edges. Report UVM_ERROR for mismatch, count observations and reject fewer than 100 samples. Do not mask invalid, reset or stalled values. No DUT output feeds expected values.",
  "implementation_id": "tlff_scoreboard.compare",
  "source": "tlff_pkg.sv:tlff_sequence.body; tlff_scoreboard.compare"
}

{
  "test_id": "T3",
  "feature_ids": [
    "F3"
  ],
  "requirement_ids": [
    "R-p8-tlff-003"
  ],
  "stimulus": "Begin with reset high across a rising edge, then drive the following phases. On pair 1 A and D vary each full-width field and both valid/ready controls independently during reset. After a reset edge execute legal operations 0 through 5 at sizes 0 through 5 subject to operation limits, all legal pair-one sources, and AcquireBlock size 6 at address 0x80000000 followed by Grant and E acknowledgement at every sink. Keep multibeat headers stable and separate request and response first beats.",
  "expected": "Pair 1 independently forwards A valid and all A fields from auto_in_1 to auto_out_1, and A ready in the reverse direction. It forwards D valid and all D fields from auto_out_1 to auto_in_1, and D ready in the reverse direction. The preserved fields are opcode, param, size, source, address, mask, data and corrupt for A, and opcode, param, size, source, sink, denied, data and corrupt for D.",
  "checker": "The self-contained independent dvbench_model computes expected native values from submitted input signals alone. tlff_scoreboard compares every actual native output to a separate expected signal using four-state inequality two time units after falling and rising edges. Report UVM_ERROR for mismatch, count observations and reject fewer than 100 samples. Do not mask invalid, reset or stalled values. No DUT output feeds expected values.",
  "implementation_id": "tlff_scoreboard.compare",
  "source": "tlff_pkg.sv:tlff_sequence.body; tlff_scoreboard.compare"
}

{
  "test_id": "T4",
  "feature_ids": [
    "F4"
  ],
  "requirement_ids": [
    "R-p8-tlff-004"
  ],
  "stimulus": "Begin with reset high across a rising edge, then drive the following phases. During reset vary all B, C and E fields and controls independently, including corrupt, all source and sink bits, contrasting data and address values. After a reset edge present B with params 0,1,2 at aligned address zero; exercise C ProbeAck and ProbeAckData at size 3 and Release and ReleaseData at size 6, with matched ReleaseAck responses after release first acceptance. Execute valid Grant/E histories for all four sinks.",
  "expected": "Pair 1 forwards B valid, param and address from auto_out_1 to auto_in_1, and B ready in the reverse direction. It forwards C valid, opcode, param, size, source, address, data and corrupt from auto_in_1 to auto_out_1, and C ready in the reverse direction. It forwards E valid and sink from auto_in_1 to auto_out_1. E has no ready signal. Every field is preserved independently of other channels.",
  "checker": "The self-contained independent dvbench_model computes expected native values from submitted input signals alone. tlff_scoreboard compares every actual native output to a separate expected signal using four-state inequality two time units after falling and rising edges. Report UVM_ERROR for mismatch, count observations and reject fewer than 100 samples. Do not mask invalid, reset or stalled values. No DUT output feeds expected values.",
  "implementation_id": "tlff_scoreboard.compare",
  "source": "tlff_pkg.sv:tlff_sequence.body; tlff_scoreboard.compare"
}

{
  "test_id": "T5",
  "feature_ids": [
    "F5"
  ],
  "requirement_ids": [
    "R-p8-tlff-005"
  ],
  "stimulus": "Begin with reset high across a rising edge, then drive the following phases. Drive 300 cycles of independently randomized full-width binary inputs with reset asserted, including every valid and ready combination in seeded random traffic. Observe outputs both before and after rising edges. Deassert reset after its rising edge and run legal normal traffic on each pair/channel. Change unrelated pair and channel fields independently, including invalid cycles and reset cycles, and compare every output without valid guarding.",
  "expected": "All 55 native outputs follow their corresponding current inputs combinationally, without a clock edge, queue, buffering, reordering or stored output. The same equalities hold for invalid and stalled channels and while reset is asserted. Reset does not gate valid, ready or payload. The two port pairs and all channels are independent. clock has no direct output-latency effect; active-high synchronous reset initializes and aborts only the legal-history checking described in the input domain.",
  "checker": "The self-contained independent dvbench_model computes expected native values from submitted input signals alone. tlff_scoreboard compares every actual native output to a separate expected signal using four-state inequality two time units after falling and rising edges. Report UVM_ERROR for mismatch, count observations and reject fewer than 100 samples. Do not mask invalid, reset or stalled values. No DUT output feeds expected values.",
  "implementation_id": "tlff_scoreboard.compare",
  "source": "tlff_pkg.sv:tlff_sequence.body; tlff_scoreboard.compare"
}
