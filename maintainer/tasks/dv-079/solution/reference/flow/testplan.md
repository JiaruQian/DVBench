## T-001

feature_ids: ["F-001"]

requirement_ids: ["R-PONG-25B-001"]

stimulus: First run until a nonzero image appears; assert the low reset between two source clock edges, check that the outputs are zero between edges, hold for 8 cycles, then deassert and check the first two cycles and another reset.

expected: reset_n is an active-low asynchronous reset. After assertion, RGB, horizontal sync, and vertical sync are all zero, the scan coordinates are (0,0), and the divide-by-two phase is zero; the upper boundaries of both paddles are 220, the ball's upper-left corner is (280,280), and both directions are negative. After deassertion, the first input rising edge only toggles the phase, and the second rising edge begins advancing the pixel coordinates. All inputs are definite binary values, driven after falling edges; observe outputs after rising-edge propagation has settled. An inter-edge reset must also immediately clear all three types of outputs to zero.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-1

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-002

feature_ids: ["F-002"]

requirement_ids: ["R-PONG-25B-002"]

stimulus: Run with the native clock for at least three field periods, comparing horizontal and vertical sync and points adjacent to wraparound pixel by pixel; continue running across the shortened boundary at row 524 and measure the anchor period.

expected: Advance one pixel every two source clock cycles. The horizontal coordinate cycles through 0..799, and the vertical coordinate increments by one when the horizontal coordinate wraps around; after the vertical coordinate reaches 524, it immediately returns to zero on the next pixel, so row 524 contains only one pixel at horizontal coordinate 0, and a full 525 rows must not be assumed. After settling, the interval between frame anchors is 838400 source cycles. Horizontal sync is low when the advanced horizontal coordinate is in 656..751; vertical sync is low when the advanced vertical coordinate is in 490..491. They are high otherwise, and reset overrides the above decoding.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-2

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-003

feature_ids: ["F-003"]

requirement_ids: ["R-PONG-25B-003"]

stimulus: Use native scanning to traverse the visible and blanking regions, checking independent pixel predictions against actual RGB and sync at both pixel phases, the four edges of the paddles, and the background.

expected: The visible region has horizontal coordinate<640 and vertical coordinate<480. Outside the visible region, the color is 000; inside, the left paddle has first priority with 001, followed by the right paddle with 010, then the ball with 100, and the background with 110. The left paddle's horizontal range is 100..105, and the right paddle's is 550..555; both vertical ranges include the upper boundary through upper boundary+80, totaling 81 rows. On each source rising edge, RGB registers the color determined by the coordinates and game state before that edge, so after a scan-advancing edge, sync corresponds to the new coordinates while RGB still corresponds to the old coordinates.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-3

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-004

feature_ids: ["F-004"]

requirement_ids: ["R-PONG-25B-004"]

stimulus: Apply short presses and bouncing for several dozen cycles each, then hold continuously for more than 2097153 cycles; check the paddle image before and after frame updates. Prepare releases shorter than the threshold, cancellation by pressing again, and concurrent activation of both bits using actual source cycles.

expected: Each low bit of btn indicates a press. Each bit is independent: after a press is first sampled while idle, the timer is cleared to zero, and the press becomes active only after it subsequently remains pressed for a full 2097152 source cycles; a release during this interval cancels timing. Once the press is active, the first sampled release starts release timing of the same duration, during which the state remains pressed; pressing again during this interval cancels the release. btn[0] is up, and btn[1] is down; when both bits are active, up takes priority if the up condition is satisfied, otherwise down can still be performed.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-4

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-005

feature_ids: ["F-005"]

requirement_ids: ["R-PONG-25B-005"]

stimulus: Hold the buttons and run in actual time to the upper and lower limits, then hold for multiple more frames to verify saturation; check the two 10-row movements and the right player's single movement around the first threshold and in the update window.

expected: The game is updated when the horizontal coordinate is 0 and the vertical coordinate is 500. These coordinates persist for two source cycles, so two consecutive updates occur per frame, with the second using the new state from the first. On each update, if up is active and the paddle's upper boundary>80, subtract 10; otherwise, if down is active and the upper boundary<400, add 10. The initial position is 220, and reachable positions are spaced by 10; at boundaries 80 and 400, no further movement in the same direction occurs. The right player uses the previously registered UART command; on each update edge, movement uses the old command first, and then the command is cleared, so without the influence of other commands, the right paddle typically moves only once by 10 rows.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-5

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-006

feature_ids: ["F-006"]

requirement_ids: ["R-PONG-25B-006"]

stimulus: Advance natively from reset for at least 145 frames, use real button inputs to preset the paddle to 80, and observe the left-paddle collision and subsequent ball trajectory. Separately, run from reset with the paddle held at the middle position until the bounce at the upper boundary; internal acceleration is prohibited.

expected: On each frame update, the ball moves by 1 in its direction, which is initially negative. Reverse the horizontal direction when the ball's horizontal coordinate is in 100..105 or 550..555 and its vertical interval [ball y,ball y+7] intersects the corresponding paddle's vertical interval; otherwise, reverse when the horizontal coordinate<=5 or the horizontal coordinate+7>=640. Reverse the vertical direction when the vertical coordinate<=5 or the vertical coordinate+7>=480. Movement uses the new direction calculated in that update, and the state wraps around as 10-bit unsigned values; there are two updates per frame, including the possibility of another reversal in two consecutive checks.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-6

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-007

feature_ids: ["F-007"]

requirement_ids: ["R-PONG-25B-007"]

stimulus: Use native scanning to check each shape bit in all eight rows during the initial diagonal movement, and check the case where the ball color no longer appears in the ball's bounding box after the horizontal and vertical directions separate; also check priority and blanking.

expected: The ball's bounding box spans 8 pixels in each of the horizontal and vertical dimensions, inclusive from the upper-left corner through +7. Shape rows 0 through 7 are, in order, hexadecimal 18, 3c, 7e, ff, ff, 7e, 3c, 18. The row number is pixel y minus ball y; the actual column index is pixel x minus ball y (this is ball y, not ball x). The ball is drawn only when the index is in 0..7 and the corresponding bit in that row is 1. Out-of-range bit indices do not produce the ball color; this fixed behavior must not be corrected to an ideal circular ball.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-7

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-008

feature_ids: ["F-008"]

requirement_ids: ["R-PONG-25B-008"]

stimulus: Send 77, 73, and non-command bytes at different starting phases; use complete start/eight-data-bit/stop-bit sequences, check the right paddle in the next frame image, and independently reconstruct the reception history.

expected: rx is high when idle, the start bit is low, the eight data bits are transmitted least significant bit first, and there is no parity. The source clock generates a 16x sampling tick every 326 cycles; after detecting a low start, data reception begins on the 8th tick, and one bit is shifted in every 16 ticks. After 8 bits, there is a transition lasting one source cycle, and reception then completes on the first subsequent tick. The stop stage waits for only one tick, and framing errors do not prevent enqueueing. Valid serial stimulus must hold each bit for 5216 source cycles and switch away from source rising edges; there is no need to rely on undisclosed error flags.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-8

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-009

feature_ids: ["F-009"]

requirement_ids: ["R-PONG-25B-009"]

stimulus: Send six alternating commands within one field to cause full/discard conditions, then consume them across multiple native fields; check retained commands, two reads, non-command bytes, and an empty buffer. Avoid using internal queue probes as the reference.

expected: The receive buffer has depth 4, with asynchronous reads of the current head byte. On reset, the pointers are 0, full=0, and empty=0; while reset remains asserted, the head slot is cleared to zero, and the remaining old slots are not guaranteed to contain new data. For a write only, write and advance the tail if not full; discard if full. For a read only, advance the head and update the flags if not empty. For simultaneous read and write in the same cycle, both pointers advance and the flags hold, while the storage write is still restricted by the original full value. There are two reads per frame-update window. When not empty, a head byte of 73 sets the down command 10, and a head byte of 77 sets the up command 01; other bytes retain the old command. Clearing the command in the frame window takes priority. The command register has a one-source-cycle delay; movement must not occur directly for each received byte.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-9

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-010

feature_ids: ["F-010"]

requirement_ids: ["R-PONG-25B-010"]

stimulus: The full-port TB drives only clk/reset_n/btn/rx, compares the three types of public outputs, and checks stimulus histories with multiple different seeds, without using force, bind, or internal hierarchy.

expected: The public top level has only VGA outputs; neither the UART transmitter nor the internal error status is exposed externally. There is no score, game over, ready/valid, writable state, or backdoor; this task retains the complete system and verifies it using native input history and public outputs, without requiring proof of unobservable transmitter/error-flag behavior. There is no parameter-based acceleration; all clock division and debouncing use the actual cycle counts stated above.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-10

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body
