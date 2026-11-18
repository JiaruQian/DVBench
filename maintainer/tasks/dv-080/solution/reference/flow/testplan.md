## T-axi-01

feature_ids: ["F-axi-01"]

requirement_ids: ["R-dv-080-001"]

stimulus: Use the exact default configuration, with each of all 4 s ports issuing read and write transactions to all 4 m ports; assign distinct addresses, IDs, payloads, and attributes to different ports, and check routing and low-order indexing in every legal valid window. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: Fix the default 4 s-side request ports and 4 m-side target ports, with DATA_WIDTH=32, ADDR_WIDTH=32, STRB_WIDTH=4, ID_WIDTH=8, each USER_WIDTH=1, all USER_ENABLE=0, FORWARD_ID=0, and M_REGIONS=1. Each M_ADDR_WIDTH=24, M_BASE_ADDR=0 uses automatic regions, all M_CONNECT_READ/WRITE connections are enabled, and M_SECURE=0. Lower port indices occupy the low-order bits of packed vectors; do not change to 1×1 or enable user/ID forwarding.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-02

feature_ids: ["F-axi-02"]

requirement_ids: ["R-dv-080-002"]

stimulus: First establish nonempty W/R buffers or a blocked B response through native transactions, then assert rst on a falling edge and hold it across multiple rising edges; check that there is no asynchronous clearing before the edge and that all ready/valid are 0 after the edge, then issue transactions again after deassertion. Block each channel separately and hold valid and payload until handshake. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: Sample on the rising edge of clk; rst is an active-high synchronous reset. After the reset edge, all output ready and valid signals for AW/AR/W/B/R are cleared to zero, and unfinished transactions are discarded; invalid payload is not required to be zeroed or held. Drives change on falling edges; while valid waits for ready, its payload remains stable, and a handshake is valid only on a rising edge where valid and ready are both 1; ready may change freely. Restart transactions after reset deassertion; legal inputs contain no X/Z.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-03

feature_ids: ["F-axi-03"]

requirement_ids: ["R-dv-080-003"]

stimulus: Have all 4 s ports hold AW and AR requests simultaneously, marking the 8 requests with different addresses and IDs; complete data and responses according to the selected transaction, check the round-robin order, block the final R beat or B to verify that other addresses cannot get ahead, and cover wraparound with two consecutive rounds. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: Globally, only one transaction is serviced at a time; among the 8 requests, index 2*n is AW for s[n], and 2*n+1 is AR. After reset, round-robin priority starts from the lowest index; after selection, the next starting point is the selected index+1, with wraparound; grant remains held until the corresponding s-side B handshake or Rlast handshake. AW/AR completion must not release it early; simultaneous reads and writes and different request ports are serialized according to this rule.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-04

feature_ids: ["F-axi-04"]

requirement_ids: ["R-dv-080-004"]

stimulus: From idle, issue a read or write request on a falling edge, record address ready, decoding, and m address valid edge by edge, and separately insert multiple cycles of low m_awready/arready; check the exact latency, that there is only one s address handshake, and that m address fields are held. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: In idle, a request first wins arbitration on one rising edge; the next rising edge captures the address fields and sets the corresponding s_awready or s_arready to 1, and the address handshake occurs on the following rising edge. Decoding occurs on that handshake edge; after the edge, a legal write enables the corresponding s_wready, and a legal read enables m_rready; the following rising edge produces the corresponding m_awvalid or m_arvalid. The m address valid remains asserted until a handshake with target ready; a new address is accepted only at the next idle service opportunity after global response completion.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-05

feature_ids: ["F-axi-05"]

requirement_ids: ["R-dv-080-005"]

stimulus: For all s/m combinations, read and write the first and last addresses of each region and adjacent boundaries, randomize all address attributes, and include len0/1/3/255 and every legal burst value; check that only the correct target has valid asserted and check all pass-through attributes, and separately test out-of-region read and write misses. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: The four target regions, in order, are 0x00000000–0x00ffffff, 0x01000000–0x01ffffff, 0x02000000–0x02ffffff, and 0x03000000–0x03ffffff; other addresses miss. The target AW/AR address, len, size, burst, lock, cache, prot, and qos pass through the original request, with region=0, user=0, and downstream ID=0. Addresses are not incremented per beat or split, and burst counting is maintained by the endpoints; valid is 0 for unselected targets.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-06

feature_ids: ["F-axi-06"]

requirement_ids: ["R-dv-080-006"]

stimulus: Perform multi-beat write bursts for all s/m combinations, with distinct data and strb values of 0/single byte/full word and random values, sending both continuous beats and valid gaps; initially hold m_wready low to fill two beats, then alternate it high, holding the beat when the source is blocked, and check capacity, latency, order, and exactly one Wlast. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: The selected write transaction receives W from the corresponding s port, and sends Wdata/strb/last in order to the selected m port, with Wuser fixed at 0. The W path has an elastic capacity of two beats; a handshaken beat can become m_wvalid after that edge. Valid output payload remains stable while blocked, with no loss, duplication, or reordering. s_wready is a registered output, enabled for the next cycle if the target is ready or if unoccupied buffer space remains after the update; acceptance by the current ready determines whether data enters the buffer on this edge. After receiving Wlast, stop receiving W for this transaction and move to waiting for B.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-07

feature_ids: ["F-axi-07"]

requirement_ids: ["R-dv-080-007"]

stimulus: Use different IDs for write requests, deliberately make m_bid different from the request, and exercise Bresp values 00/01/10/11; delay B and hold the response while s_bready is low, checking the true source ID, target uniqueness, and blocking of other requests while waiting. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: Enable the selected m_bready after the edge that receives upstream Wlast; a legal endpoint supplies B only after the target AW and all W have handshaken. After the downstream B handshake, assert Bvalid to the selected s port after the edge, with Bresp passed through, Bid equal to the original AWID rather than m_bid, and Buser=0. Hold Bvalid and valid payload while s_bready is low; the final s-side B handshake releases arbitration, and no other s port has Bvalid asserted.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-08

feature_ids: ["F-axi-08"]

requirement_ids: ["R-dv-080-008"]

stimulus: Read 1/2/4/8/256 beats for all s/m combinations, with distinct data/resp for each beat and deliberately different downstream IDs; use continuous R and gapped R with upstream ready low to fill two beats, then release and apply alternating backpressure, checking order, last, source ID, and that blocking the final beat does not release the grant. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: The selected read transaction receives R only from the selected m port; Rdata/resp/last pass through beat by beat to the original s port, with Rid always equal to the original ARID rather than m_rid, and Ruser=0. The R path has an elastic capacity of two beats; valid payload remains stable while blocked, with no loss, duplication, or reordering; upstream ready and capacity determine registered m_rready. After receiving target Rlast, stop receiving downstream R, and release arbitration only after that final beat handshakes on the s side; normal reads do not generate or truncate data on their own based on ARLEN.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-09

feature_ids: ["F-axi-09"]

requirement_ids: ["R-dv-080-009"]

stimulus: Have the four s ports read out-of-region addresses with len0/1/3/255, keeping m_rvalid0; hold s_rready low initially and then receive intermittently, independently counting to check exactly len+1 beats, the final marker, 0data, and DECERR, and checking that there is no m_arvalid on any port. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: An address miss sends no AR to any m port. Internally generate ARLEN+1 Rbeat entries, with data 0, resp=2'b11, namely DECERR, Rid equal to the request ID, and user0, with last1 only on the final beat; obey the same R buffering and upstream backpressure, completing the transaction after all are received, and do not allow the count to overflow and cause endless sending.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-10

feature_ids: ["F-axi-10"]

requirement_ids: ["R-dv-080-010"]

stimulus: Perform out-of-region writes of 1/multiple beats and insert valid gaps before Wlast, deliberately making AWLEN differ from the Wlast position; check that there are no downstream AW/W handshakes, no B before last, and only one DECERR after last; block B, then release it and issue the next transaction. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: An address miss sends no AW or W to any m port. Receive and discard W from the selected s port, returning one B to that s port only upon the Wlast handshake, with resp=2'b11, namely DECERR, Bid equal to the original AWID, and user0. AWLEN does not replace Wlast as the termination condition; hold the response under upstream B backpressure.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-11

feature_ids: ["F-axi-11"]

requirement_ids: ["R-dv-080-011"]

stimulus: Alternate targets 0/1/3/2 in successive reads, keeping m_rvalid at 0 before AR; compare edge by edge that ready uses the old target in the first cycle after decoding and the new target in the next cycle, and send R only after the target AR completes. Make the first read target after the initial reset nonzero to check the initial value of 0; reset again after a nonzero target history to check index retention, and also cover being in the decode stage before the reset edge. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: In the first cycle after a legal read address handshake, the onehot position of m_rready uses the target index saved by the previous decode, whose initial value at the start of simulation is 0; synchronous reset does not clear the saved target index to zero, and the reset edge still commits the index obtained from combinational decoding before reset, with the subsequent first cycle projected according to this historical index; starting in the next cycle, the current target index is used. Validity depends on the read-buffer availability condition at that time. A legal endpoint does not send R before the corresponding AR handshake, so this ready projection cannot create data out of thin air; this item only exposes the exact timing of the control output.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.

## T-axi-12

feature_ids: ["F-axi-12"]

requirement_ids: ["R-dv-080-012"]

stimulus: Compare cycle by cycle under combinations of valid0/1 and backpressure on all channels, independently comparing ready/valid on each port and comparing payload only when both sides have valid1; check the current handshake before the edge, wait 1ns after the edge to compare updates, and report both valid differences and valid X/Z as errors. Drive on the falling edge and hold payload until its valid/ready handshake; sample stable values before each rising edge and sample after waiting 1ns after the edge, with handshakes determined by the old ready and valid. Always compare controls, compare valid payload, and do not score before the initial synchronous reset.

expected: All output ready/valid signals are meaningful in the stable windows before and after every edge once reset has occurred; payload is valid only when its port's valid is 1. Payload may display the same value on multiple ports; payload on unselected ports with valid0 is not scored and is not required to be 0. Comparison of valid differences must independently report errors; control mismatches must not be masked because actual or expected has valid0; X/Z at a valid point is an error.

checker: Predict from input history using an independent transaction and beat-queue model; the monitor reads the actual native ports, and the scoreboard performs field-by-field four-state comparisons by request/beat sequence number; independently report valid differences, report UVM_ERROR for valid X/Z or data/routing/order/beat-count mismatches, and check that all transactions have drained and the comparison count is nonzero at completion; do not use DUT outputs as expected.

implementation_id: axi_reference_sequence

source: tb.sv; model/model.sv; semantic coverage objectives and current HDL execution coverage are accepted separately; do not falsely claim dynamic completion in text.
