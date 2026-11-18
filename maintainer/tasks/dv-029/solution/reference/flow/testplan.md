### T-001
test_id: T-001
feature_ids: F-001
requirement_ids: R-dv-029-001
stimulus: All requests low, ack low, saveBGBlock=0; first span 2 effective reset edges.; Change the active-low reset between edges to confirm that state is not cleared immediately, then cross an edge; perform operations after legally writing the cache/colors respectively, and observe Z on the undriven FIFO outputs.
expected: Synchronous control reset; do not assume unreset storage is cleared to 0, and do not check its data values before legal establishment.
checker: Predict independently from protocol state and input history; compare actual/expected using four-state comparison in legal valid windows; report errors for X/Z valid data, and require both undriven FIFO outputs to be Z. Actual sampling windows for this test: Bus outputs are combinational functions of the current state/inputs and may be sampled before the edge after the inputs have been stable for 1ns; sequential state updates on the gpuClk edge.
implementation_id: V-001
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-002
test_id: T-002
feature_ids: F-002
requirement_ids: R-dv-029-002
stimulus: Apply synchronous reset and clear all requests, with ack low.; Assert the four request types individually and simultaneously; with idle ack high/low, compare the first-beat address, cnt, and direction; hold the command and then clear it.
expected: Independent priority and byte-alignment calculations, without assuming BG writes have priority or FIFO queuing based on source-code comments.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: request selection uses pre-edge combinational values, and the active transaction is latched on the rising edge; subsequent cnt defaults to 0.
implementation_id: V-002
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-003
test_id: T-003
feature_ids: F-003
requirement_ids: R-dv-029-003
stimulus: A transaction has already been selected on the first beat with ack low and has entered the active state across an edge.; Hold ack high for 1/2/8/9 consecutive beats, changing dat_i each beat, then hold ack low across an edge; verify early termination and index wraparound.
expected: Count and terminate according to input ack history, rather than constructing expectations from DUT req feedback.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: first stabilize ack during the low phase, check the current beat address before the edge, and check the advanced outputs after the edge; cnt denotes length only on the first beat.
implementation_id: V-003
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-004
test_id: T-004
feature_ids: F-004
requirement_ids: R-dv-029-004
stimulus: With idle ack low, clear other requests.; Issue command 1 at each mask/pair boundary, and issue fill command 2; change the command color while active, and observe each beat with ack high.
expected: Independently decode color/mask/byte address; write data must equal the latched fields.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: color and mask are latched at the initiation edge, and wrt=1 while active with ack high; the first beat still uses the default read direction.
implementation_id: V-004
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-005
test_id: T-005
feature_ids: F-005
requirement_ids: R-dv-029-005
stimulus: Clear other requests; after the first beat, hold the address request until activity ends.; For L/R/dual requests respectively, hold ack high for 2 beats and provide different data on each, then provide a third value on the terminating low beat; check completion and writeback in each window.
expected: Independently record the initiating side and beat 0; termination data concatenates the current upper half with the first-beat lower half.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: the completion side and TexCacheWrite occupy different windows; the upper half of the data directly follows dat_i, sampled 1ns into the termination cycle.
implementation_id: V-005
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-006
test_id: T-006
feature_ids: F-006
requirement_ids: R-dv-029-006
stimulus: With no higher-priority requests and idle ack low, issue CLUT.; Provide 8 distinct dat_i values, sample separately before and after the edge, and confirm the pipeline-tail write flag after termination; test early termination after 1 beat.
expected: Independent beat tracking and a one-cycle write-index pipeline, with data passed through from the current input.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: check the pre-edge address/completion separately from the post-edge write flag/index; the data itself has no corresponding register.
implementation_id: V-006
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-007
test_id: T-007
feature_ids: F-007
requirement_ids: R-dv-029-007
stimulus: First hold saveBGBlock at 0 across an edge; establish available data from a complete 8-beat background read.; For all block/blending combinations respectively, check the write mask and active address, write termination and the subsequent read phase; after completion, keep the value nonzero, then return it to 0 to retrigger.
expected: Independent edge history, block queue, and 8-word array, without backfilling from imported actual values.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: set busy on the first beat and clear busy on the final termination edge; the background cache is valid only after a legal read history, and source-side save/load/export remain stable until completion.
implementation_id: V-007
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-008
test_id: T-008
feature_ids: F-008
requirement_ids: R-dv-029-008
stimulus: Apply synchronous reset; first perform an 8-beat read command 3 for each of the two banks.; Load both banks word by word with different dat_i values, covering mask modes and clear-other respectively, then observe using subsequent command 4.
expected: Independent two-bank arrays of 16 halfwords and pixel masks; the read cache itself has no public direct port and is verified through writeback.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: the read-bank cache is written by active beats and their index pipeline; use the writeback command only after termination.
implementation_id: V-008
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-009
test_id: T-009
feature_ids: F-009
requirement_ids: R-dv-029-009
stimulus: Both banks have been filled by legal reads of different data, and both masks have been established.; Iterate over VVIndex, bank, and force/check, with alternating stencil and all-0/1 stencil; after clearing the bank at the end, issue writeback again to observe mask clearing.
expected: An independent circular array of 32 16-bit pixels, assembling words using arithmetic indices; independent Boolean operations for mask and stencil.
checker: Predict using independent protocol state and input history; perform four-state actual/expected comparisons in legally valid windows; report errors for X/Z valid data, and require the two undriven FIFO outputs to be Z. Actual sampling windows in this test: bank, rotation, stencil, force/check, and bank-clear control are latched on the first beat; observe each beat while active with ack high.
implementation_id: V-009
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write
