## F-001

requirement_ids: ["R-PONG-25B-001"]

module: pong_top

definition: reset_n is an active-low asynchronous reset. After assertion, RGB, horizontal sync, and vertical sync are all zero, the scan coordinates are (0,0), and the divide-by-two phase is zero; the upper boundaries of both paddles are 220, the ball's upper-left corner is (280,280), and both directions are negative. After deassertion, the first input rising edge only toggles the phase, and the second rising edge begins advancing the pixel coordinates. All inputs are definite binary values, driven after falling edges; observe outputs after rising-edge propagation has settled. An inter-edge reset must also immediately clear all three types of outputs to zero.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-002

requirement_ids: ["R-PONG-25B-002"]

module: pong_top

definition: Advance one pixel every two source clock cycles. The horizontal coordinate cycles through 0..799, and the vertical coordinate increments by one when the horizontal coordinate wraps around; after the vertical coordinate reaches 524, it immediately returns to zero on the next pixel, so row 524 contains only one pixel at horizontal coordinate 0, and a full 525 rows must not be assumed. After settling, the interval between frame anchors is 838400 source cycles. Horizontal sync is low when the advanced horizontal coordinate is in 656..751; vertical sync is low when the advanced vertical coordinate is in 490..491. They are high otherwise, and reset overrides the above decoding.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-003

requirement_ids: ["R-PONG-25B-003"]

module: pong_top

definition: The visible region has horizontal coordinate<640 and vertical coordinate<480. Outside the visible region, the color is 000; inside, the left paddle has first priority with 001, followed by the right paddle with 010, then the ball with 100, and the background with 110. The left paddle's horizontal range is 100..105, and the right paddle's is 550..555; both vertical ranges include the upper boundary through upper boundary+80, totaling 81 rows. On each source rising edge, RGB registers the color determined by the coordinates and game state before that edge, so after a scan-advancing edge, sync corresponds to the new coordinates while RGB still corresponds to the old coordinates.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-004

requirement_ids: ["R-PONG-25B-004"]

module: pong_top

definition: Each low bit of btn indicates a press. Each bit is independent: after a press is first sampled while idle, the timer is cleared to zero, and the press becomes active only after it subsequently remains pressed for a full 2097152 source cycles; a release during this interval cancels timing. Once the press is active, the first sampled release starts release timing of the same duration, during which the state remains pressed; pressing again during this interval cancels the release. btn[0] is up, and btn[1] is down; when both bits are active, up takes priority if the up condition is satisfied, otherwise down can still be performed.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-005

requirement_ids: ["R-PONG-25B-005"]

module: pong_top

definition: The game is updated when the horizontal coordinate is 0 and the vertical coordinate is 500. These coordinates persist for two source cycles, so two consecutive updates occur per frame, with the second using the new state from the first. On each update, if up is active and the paddle's upper boundary>80, subtract 10; otherwise, if down is active and the upper boundary<400, add 10. The initial position is 220, and reachable positions are spaced by 10; at boundaries 80 and 400, no further movement in the same direction occurs. The right player uses the previously registered UART command; on each update edge, movement uses the old command first, and then the command is cleared, so without the influence of other commands, the right paddle typically moves only once by 10 rows.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-006

requirement_ids: ["R-PONG-25B-006"]

module: pong_top

definition: On each frame update, the ball moves by 1 in its direction, which is initially negative. Reverse the horizontal direction when the ball's horizontal coordinate is in 100..105 or 550..555 and its vertical interval [ball y,ball y+7] intersects the corresponding paddle's vertical interval; otherwise, reverse when the horizontal coordinate<=5 or the horizontal coordinate+7>=640. Reverse the vertical direction when the vertical coordinate<=5 or the vertical coordinate+7>=480. Movement uses the new direction calculated in that update, and the state wraps around as 10-bit unsigned values; there are two updates per frame, including the possibility of another reversal in two consecutive checks.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-007

requirement_ids: ["R-PONG-25B-007"]

module: pong_top

definition: The ball's bounding box spans 8 pixels in each of the horizontal and vertical dimensions, inclusive from the upper-left corner through +7. Shape rows 0 through 7 are, in order, hexadecimal 18, 3c, 7e, ff, ff, 7e, 3c, 18. The row number is pixel y minus ball y; the actual column index is pixel x minus ball y (this is ball y, not ball x). The ball is drawn only when the index is in 0..7 and the corresponding bit in that row is 1. Out-of-range bit indices do not produce the ball color; this fixed behavior must not be corrected to an ideal circular ball.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-008

requirement_ids: ["R-PONG-25B-008"]

module: pong_top

definition: rx is high when idle, the start bit is low, the eight data bits are transmitted least significant bit first, and there is no parity. The source clock generates a 16x sampling tick every 326 cycles; after detecting a low start, data reception begins on the 8th tick, and one bit is shifted in every 16 ticks. After 8 bits, there is a transition lasting one source cycle, and reception then completes on the first subsequent tick. The stop stage waits for only one tick, and framing errors do not prevent enqueueing. Valid serial stimulus must hold each bit for 5216 source cycles and switch away from source rising edges; there is no need to rely on undisclosed error flags.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-009

requirement_ids: ["R-PONG-25B-009"]

module: pong_top

definition: The receive buffer has depth 4, with asynchronous reads of the current head byte. On reset, the pointers are 0, full=0, and empty=0; while reset remains asserted, the head slot is cleared to zero, and the remaining old slots are not guaranteed to contain new data. For a write only, write and advance the tail if not full; discard if full. For a read only, advance the head and update the flags if not empty. For simultaneous read and write in the same cycle, both pointers advance and the flags hold, while the storage write is still restricted by the original full value. There are two reads per frame-update window. When not empty, a head byte of 73 sets the down command 10, and a head byte of 77 sets the up command 01; other bytes retain the old command. Clearing the command in the frame window takes priority. The command register has a one-source-cycle delay; movement must not occur directly for each received byte.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-010

requirement_ids: ["R-PONG-25B-010"]

module: pong_top

definition: The public top level has only VGA outputs; neither the UART transmitter nor the internal error status is exposed externally. There is no score, game over, ready/valid, writable state, or backdoor; this task retains the complete system and verifies it using native input history and public outputs, without requiring proof of unobservable transmitter/error-flag behavior. There is no parameter-based acceleration; all clock division and debouncing use the actual cycle counts stated above.

interface: ["clk", "reset_n", "btn", "rx", "vga_hsync", "vga_vsync", "vga_rgb"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.
