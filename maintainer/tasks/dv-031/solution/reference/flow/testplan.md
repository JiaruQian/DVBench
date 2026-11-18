### T-001
test_id: T-001
feature_ids: F-001
requirement_ids: R-dv-031-001
stimulus: Hold both clocks low for at least 110ns, then run each for 12 rising edges with write enables at 0; avoid cross-port collisions.; Through port A, write alternating-bit, all-0, all-1, and walking-bit patterns address by address, and read back the first and last addresses and all addresses; change inputs during the low phase and check pre-edge holding; cover all data bits with random reads and writes.
expected: Predict using an independent array and a registered read port updated on its own edges; in a write cycle, the value is the new input value.
checker: Perform four-state comparisons of valid dout; separately compare pre-edge holding and post-edge values, report UVM_ERROR on mismatch, and require reads and writes of all addresses to complete. Actual sampling window for this test: Data and address are stable before the edge; the output is sampled at least 1ns after the edge and holds when there is no new rising edge at that port. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-001
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-002
test_id: T-002
feature_ids: F-002
requirement_ids: R-dv-031-002
stimulus: Complete startup and establish nonzero data and outputs at different addresses on the two ports.; Separately assert/deassert rsta between edges, holding it for 1/3 edges; write nonzero data through that port during reset, read it back from both ports after deassertion, and keep the other port operating.
expected: Only the output of the port being reset becomes 0 synchronously; memory and the other port's state are retained, and writes during reset are visible in subsequent readback.
checker: Predict using an input-history array and perform four-state comparisons between edges and after edges; reset must not be treated as clearing memory. Actual sampling window for this test: Changing reset between edges does not immediately clear the output; it is 0 at 1ns after the assertion edge, and normal reads and writes resume on the next edge of its own clock after deassertion. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-002
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-003
test_id: T-003
feature_ids: F-003
requirement_ids: R-dv-031-003
stimulus: busy is low after 12 startup edges; control the two ports' clocks separately.; Assert only rsta for one edge of its own clock and then deassert it, checking 1/1/0 edge by edge; then reassert it in the tail window, pause clka, and advance only the other port.
expected: Independently count the reset history of the two most recent edges; busy is the registered result of ORing the current reset with the two historical values.
checker: Perform four-state comparisons of busy edge by edge and count, checking holding between edges/while the clock is stopped; waiting for busy to clear itself must not replace bounded checks. Actual sampling window for this test: busy changes only on its own rising edges and is observed 1ns after the edge; stopping that clock freezes it, and the other port's clock cannot advance it. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-003
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-004
test_id: T-004
feature_ids: F-004
requirement_ids: R-dv-031-004
stimulus: Hold both clocks low for at least 110ns, then run each for 12 rising edges with write enables at 0; avoid cross-port collisions.; Through port B, write alternating-bit, all-0, all-1, and walking-bit patterns address by address, and read back the first and last addresses and all addresses; change inputs during the low phase and check pre-edge holding; cover all data bits with random reads and writes.
expected: Predict using an independent array and a registered read port updated on its own edges; in a write cycle, the value is the new input value.
checker: Perform four-state comparisons of valid dout; separately compare pre-edge holding and post-edge values, report UVM_ERROR on mismatch, and require reads and writes of all addresses to complete. Actual sampling window for this test: Data and address are stable before the edge; the output is sampled at least 1ns after the edge and holds when there is no new rising edge at that port. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-004
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-005
test_id: T-005
feature_ids: F-005
requirement_ids: R-dv-031-005
stimulus: Complete startup and establish nonzero data and outputs at different addresses on the two ports.; Separately assert/deassert rstb between edges, holding it for 1/3 edges; write nonzero data through that port during reset, read it back from both ports after deassertion, and keep the other port operating.
expected: Only the output of the port being reset becomes 0 synchronously; memory and the other port's state are retained, and writes during reset are visible in subsequent readback.
checker: Predict using an input-history array and perform four-state comparisons between edges and after edges; reset must not be treated as clearing memory. Actual sampling window for this test: Changing reset between edges does not immediately clear the output; it is 0 at 1ns after the assertion edge, and normal reads and writes resume on the next edge of its own clock after deassertion. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-005
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-006
test_id: T-006
feature_ids: F-006
requirement_ids: R-dv-031-006
stimulus: busy is low after 12 startup edges; control the two ports' clocks separately.; Assert only rstb for one edge of its own clock and then deassert it, checking 1/1/0 edge by edge; then reassert it in the tail window, pause clkb, and advance only the other port.
expected: Independently count the reset history of the two most recent edges; busy is the registered result of ORing the current reset with the two historical values.
checker: Perform four-state comparisons of busy edge by edge and count, checking holding between edges/while the clock is stopped; waiting for busy to clear itself must not replace bounded checks. Actual sampling window for this test: busy changes only on its own rising edges and is observed 1ns after the edge; stopping that clock freezes it, and the other port's clock cannot advance it. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-006
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-007
test_id: T-007
feature_ids: F-007
requirement_ids: R-dv-031-007
stimulus: Complete startup; select different A/B addresses.; Across all addresses, alternate A writes/B reads and B writes/A reads; perform dual writes at different addresses, use clocks at different rates, pause one port and advance the other; perform dual reads at the same address.
expected: One shared independent array; only a rising edge of the corresponding port updates that port's output, and non-colliding cross-port reads observe the latest write.
checker: Independently record drive edges and addresses, excluding the explicitly defined collision domain; perform four-state comparisons of both ports' outputs without using DUT results to construct expected. Actual sampling window for this test: The two ports may have different periods and different phases; a subsequent read edge must be at least 2ns after the preceding write edge. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-007
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-008
test_id: T-008
feature_ids: F-008
requirement_ids: R-dv-031-008
stimulus: Initially, inputs are 0, clocks are low, and both write enables are low.; Wait 110ns, then advance each clock for 12 edges, traverse the initial values at all addresses, and change the clock phases to repeat subsequent reset checks.
expected: Unwritten addresses always read as 0, and busy is low after startup; subsequent user resets follow each port's contract exactly.
checker: Check all addresses after startup, reporting an error if X/Z or a nonzero value appears; ensure sufficient startup edges without forcing internal registers. Actual sampling window for this test: Write enables must be 0 during startup settling; after the 12 edge, initial values can be read and busy is 0 without an additional user reset. All post-edge checks are performed when stable at least 1ns after that port's rising edge; pre-edge and inter-edge holding checks still follow their respective drive histories.
implementation_id: V-008
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write
