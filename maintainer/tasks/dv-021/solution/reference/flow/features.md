### F-001
feature_id: F-001
requirement_ids: R-dv-021-001
module: top_stopwatch_watch
definition: rst is an active-high asynchronous reset that clears button sampling history, control state, mode, both timers, and divider remainders; both time values become zero, and the scan index becomes zero. During reset, LED bits directly driven by switches still follow sw.
interface: clk, rst, btnR, btnL, btnU, btuD, sw, fnd_com, fnd_data, led
timing: Reset takes effect immediately even when asserted between two source clock edges; after deassertion, operation continues according to the input switches and subsequent valid buttons.
boundary: Defaults are MSEC_WIDTH=7, SEC_WIDTH=6, MIN_WIDTH=6, HOUR_WIDTH=5, with fixed native clock division and no hierarchical modification allowed.

### F-002
feature_id: F-002
requirement_ids: R-dv-021-002
module: top_stopwatch_watch
definition: The four buttons are sampled once every 100000 source clock rising edges; each button must have 8 consecutive samples of 1 to generate one event. Holding a button does not repeat the event; retriggering requires at least one low sample followed by another 8 high samples.
interface: clk, rst, btnR, btnL, btnU, btuD, sw, led, fnd_data
timing: The event goes high after the 8th high sampling edge, and the controller and data editing use that event on the next source edge; buttons are not accepted directly on every source edge.
boundary: Short pulses, 7/8 high samples, interrupted highs, and long holds, with the four buttons independent; simultaneous events are handled according to control priority.

### F-003
feature_id: F-003
requirement_ids: R-dv-021-003
module: top_stopwatch_watch
definition: The initial state enters stopwatch stopped when sw[1]=0; it enters clock running when sw[1]=1 and sw[2]=0, and waits if both are 1. In stopwatch stopped, sw[1] has first priority to enter clock mode, then R to enter running, then L to enter single-cycle clear, then D to enter single-cycle direction flip. Stopwatch running accepts only sw[1] to switch to clock mode or R to stop; L/D have no effect. The clear and direction states return to stopped after one cycle.
interface: clk, rst, btnR, btnL, btuD, sw, led, fnd_data
timing: Control and direction are registered on source rising edges; direction flips on the next edge after the old direction state. All buttons are qualified events.
boundary: Priority among simultaneous R/L/D, L/D having no effect while running, clear/direction lasting only one cycle, and the stopwatch pausing when switching modes.

### F-004
feature_id: F-004
requirement_ids: R-dv-021-004
module: top_stopwatch_watch
definition: While the stopwatch is running, one registered tick is generated every 1000000 enabled source edges, and the next source edge advances the time by one hundredth of a second. Time spans 24 hours × 60 minutes × 60 seconds × 100 hundredths of a second, with incrementing carrying through successive fields; in reverse, borrowing propagates from 0 through successive fields to 23:59:59.99. Stopping freezes the divider remainder, and clearing clears the remainder; for each digit, tick takes priority over clear on the same edge.
interface: clk, rst, btnR, btnL, btuD, sw, fnd_com, fnd_data
timing: The tick-generation edge and the data-update edge are separated by one source period; after stopping, a tick already generated on the preceding edge can still be consumed.
boundary: 0/99 hundredths of a second, 0/59 seconds and minutes, 0/23 hours, and full-day wraparound; pause/resume preserves the sub-tick remainder, and counting restarts for a full interval after clearing.

### F-005
feature_id: F-005
requirement_ids: R-dv-021-005
module: top_stopwatch_watch
definition: The clock runs autonomously in all non-editing control states, generating a registered tick every 1000000 enabled edges and counting hundredths of a second on the following edge. In W_RUN, sw[1]=0 is handled first to return to stopwatch stopped; otherwise, sw[2]=1 enters editing of the seconds units digit. In an editing state, sw[2]=0 returns to W_RUN; sw[1] does not directly cause an exit during editing. Editing freezes the clock divider remainder.
interface: clk, rst, sw, btnL, btnR, led, fnd_data
timing: Switches change the control state only on source edges, while the display selection itself follows sw[1] combinationally.
boundary: The clock continues running while the stopwatch is displayed; the remainder is preserved across entry into and exit from editing, and all combinations of sw[1] and sw[2] are defined.

### F-006
feature_id: F-006
requirement_ids: R-dv-021-006
module: top_stopwatch_watch
definition: The editing cursor order is seconds units, seconds tens, minutes units, minutes tens, and hours; L moves forward and R backward, with wraparound, and L takes priority over R. U increments the current digit by 1, and D decrements it by 1, with U taking priority over D; seconds/minutes units are modulo 10, tens are modulo 6, and hours are modulo 24, with no carry or borrow between digits during editing. For a digit that actually receives tick, tick takes priority over editing.
interface: clk, rst, sw, btnR, btnL, btnU, btuD, led, fnd_com, fnd_data
timing: Qualified button events are applied on source edges; when movement and editing occur on the same edge, editing uses the old cursor.
boundary: Units 0↔9, tens 0↔5, hours 0↔23, with combined L/R and U/D priorities; unselected digits hold their values.

### F-007
feature_id: F-007
requirement_ids: R-dv-021-007
module: top_stopwatch_watch
definition: led[0]=sw[0], led[1]=sw[1], led[2]=sw[1]&!sw[2], led[3]=sw[1]&sw[2]; led4 corresponds to minutes units, led5 to minutes tens, led6 to seconds units or hours, and led7 to seconds tens; the cursor LEDs are off in other control states.
interface: sw, led, clk, rst, btnL, btnR
timing: The low 4 bits change combinationally, and the cursor bits change according to the current registered control state; reset turns the cursor off.
boundary: All 8 switch combinations, the five cursor positions, and non-editing states are defined.

### F-008
feature_id: F-008
requirement_ids: R-dv-021-008
module: top_stopwatch_watch
definition: The display combinationally selects the stopwatch or clock corresponding to sw[1]. The scan index resets to 0, reaches 1 after the first 50000 source edges, and then increments by 1 modulo 8 every 100000 edges. fnd_com follows the sequence 1110/1101/1011/0111 based only on the low 2 bits of the index. Indices 0/1 display hundredths-of-a-second units/tens (sw0=0) or minutes units/tens (sw0=1); 2/3 display seconds units/tens or hours units/tens; 4/5/7 are blank, and 6 displays a dot when hundredths of a second <=50 and is blank when >50.
interface: clk, rst, sw, fnd_com, fnd_data
timing: Changes to the scan index and the selected time take effect combinationally; sample 1ns after source edges, and switch changes between edges can also be observed.
boundary: The segment codes for digits 0..9 are C0,F9,A4,B0,99,92,82,F8,80,90 in order; the dot is 7F and blank is FF. Dot boundary 50/51, scan 7→0, and all four digit selects.
