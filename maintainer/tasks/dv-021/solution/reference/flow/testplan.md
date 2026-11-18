### T-001
test_id: T-001
feature_ids: F-001
requirement_ids: R-dv-021-001
stimulus: Establish a nonzero time, a nonzero scan index, and button history.; Assert rst during high/low phases and while a button is held, running, and editing; hold for 1/3 edges, then release.
expected: After reset, display the encoding for zero and index 0, turn the cursor LED off, and set the direction to increment; switch LEDs still reflect inputs combinationally.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: reset takes effect immediately even when asserted between two source clock edges; after deassertion, operation continues according to input switches and subsequent valid buttons.
implementation_id: V-001
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-002
test_id: T-002
feature_ids: F-002
requirement_ids: R-dv-021-002
stimulus: Clear history with asynchronous reset, with the controller in stopwatch stopped or clock editing.; Apply pulses shorter than 8 samples, 7/8 sample boundaries, long presses, release and press again, and simultaneous presses of multiple buttons, fully traversing the native sampling intervals.
expected: Produce a control/edit effect only once, on the next source edge after qualification is established; short pulses do not change state.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: the event goes high after the 8th high sampling edge, and the controller and data editing use that event on the next source edge; buttons are not accepted directly on every source edge.
implementation_id: V-002
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-003
test_id: T-003
feature_ids: F-003
requirement_ids: R-dv-021-003
stimulus: After reset, set sw[1]=0 and wait to enter stopped.; Press R to start/stop; while stopped, press L to clear to zero and D to reverse direction; press L/D while running; combine switches and buttons to test priority.
expected: Predict start/stop, clearing to zero, and direction according to the abstract control state; observe through the subsequent time display and cursor LED.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: control and direction are registered on source rising edges; direction reverses on the next edge of the old direction state. All buttons are qualified events.
implementation_id: V-003
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-004
test_id: T-004
feature_ids: F-004
requirement_ids: R-dv-021-004
stimulus: Reset to zero; start with valid buttons, and reverse borrowing can establish the boundary from 0 to the end of a full day.; Run incrementally across tick, pause for less than one tick and then resume; clear to zero, reverse direction, and then run to check borrowing and full-day wraparound; run continuously across hundredth-of-a-second and second carries.
expected: An independent mixed-radix counter updates according to the input enable history; compare segment codes in the valid window of each scan digit.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: the tick generation edge and the data update edge are separated by one source cycle; after stopping, the tick already generated on the previous edge can still be consumed.
implementation_id: V-004
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-005
test_id: T-005
feature_ids: F-005
requirement_ids: R-dv-021-005
stimulus: After reset, wait for non-editing operation, and set sw[1]=1.; Run the clock across tick, enter editing, wait more than one tick, and then exit; change sw[1] in the editing state, separately combining it with the exit switch.
expected: Predict using independent clock history and abstract editing state; time does not advance automatically during editing; after exit, continue from the remainder.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: switches change the control state only on source edges, while display selection itself follows sw[1] combinationally.
implementation_id: V-005
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-006
test_id: T-006
feature_ids: F-006
requirement_ids: R-dv-021-006
stimulus: Enter W_SET_S1; traverse the five cursors through valid L/R events.; At each cursor, use D at zero to borrow to that digit's maximum, then U to return to zero; combine movement and editing; apply U/D and L/R simultaneously.
expected: Predict using an independent decimal digit array, with each digit taking its own modulus, and compare against the cursor LED and the complete scanned display.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: button qualification events are applied on source edges; when movement and editing occur on the same edge, edit using the old cursor.
implementation_id: V-006
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-007
test_id: T-007
feature_ids: F-007
requirement_ids: R-dv-021-007
stimulus: Establish editing and non-editing states.; Traverse the switches between two clock edges and observe the low 4 bits; use valid buttons to traverse the cursors and exit/reset.
expected: Predict all LEDs from the Boolean relationships of the switches and independent state; do not infer state backward from the display.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: the low 4 bits change combinationally, and the cursor bits change according to the current registered control state; reset turns the cursor off.
implementation_id: V-007
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-008
test_id: T-008
feature_ids: F-008
requirement_ids: R-dv-021-008
stimulus: Establish a value of 0 after reset, then establish nonzero times, times with different high and low digits, and times on both sides of the dot.; Run naturally through all 8 scan slots; toggle sw0/sw1, check all digits, establish high digits through reverse borrowing; run across 50/51 and observe index 6.
expected: Determine the scan slot from the absolute count of source edges, predict using decimal decomposition of an independent time value and a segment-code table, and perform four-state comparisons.
checker: Predict independently from inputs and history, and perform four-state comparisons on native ports; report UVM_ERROR on a mismatch, require a nonzero number of valid comparisons and normal completion. Actual sampling window of this test: changes to the scan index and selected time take effect combinationally; sample 1ns after the source edge, and switch changes between edges can also be observed.
implementation_id: V-008
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write
