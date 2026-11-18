### F-1

requirement_ids: R-VRP-001
module: vga_range_plot_top/Clock, Reset, and Startup Clearing
definition: The clk_100mhz period is 10 ns. rst_sys is active high: system state is reset on the rising edge; the divider reset request is asynchronously loaded into a two-stage synchronizer, and after deassertion, zero is shifted in on each system edge. The divider uses the pre-edge second stage. The divider's internal half-count and pix_clk are cleared on reset; after release, the half-count alternates between 0 and 1, and pix_clk toggles only when the pre-edge half-count is 1, so the pixel clock is 25 MHz. The pixel reset request is also asynchronously loaded into a two-stage synchronizer, with zero shifted in on each pixel rising edge; each pixel state uses the pre-edge second stage. The pixel clock stops during reset, and pixel registers must not be assumed to asynchronously clear to zero; only a reset pixel edge after recovery clears the scan, coordinates, and RGB to zero and sets the sync signals high.

Every system edge with rst_sys high restarts initialization, with the clear address starting at 0; after deassertion, all 65536 addresses are cleared sequentially, and initialization exits on the same edge that clears the final address. Initialization takes priority over all other storage accesses; distance and decay state remain in reset, and hits cannot be accepted. Legal functional inputs must wait at least 65550 system cycles after deassertion. Scanning proceeds independently; stored read values are displayed only after initialization completion has been synchronized through two pixel edges, and intensity is treated as zero before then. Reset may be reapplied during operation, and clearing must be completed again.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-2

requirement_ids: R-VRP-002
module: vga_range_plot_top/Full Scan and Synchronization
definition: On a normal pixel edge, registered outputs are generated using the pre-edge counters, and then the counters advance: hcount goes from 0 to 799; when it returns to zero, vcount increments; vcount goes from 0 to 524 and then returns to zero. active_video is the combinational result of the current hcount<640 and vcount<480; frame_tick is true when the current hcount=0, vcount=0, and active_video is true. vga_hsync_n is low when the pre-edge hcount is within 656～751; vga_vsync_n is low when the pre-edge vcount is within 490～491. Therefore, the sync signals are one cycle related to the post-edge counters and must not be recombined using the post-edge counters.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-3

requirement_ids: R-VRP-003
module: vga_range_plot_top/Intensity Accumulation from Distance and Angle
definition: Each system rising edge on which dist_vld is high provides one polar-coordinate input; the low angle bits are not required to be zero. The horizontal coordinate x is the upper eight bits of theta_q15. First clamp dist_mm to R_MAX_MM, then let scaled=floor((clamped×255+floor(R_MAX_MM/2))/R_MAX_MM), and the vertical coordinate y=255-scaled; when R_MAX_MM=0, scaled is fixed at 0. Distance is the complete unsigned 16-bit field. The linear address is 256y+x.

A hit adds 3 to the old four-bit intensity and saturates at 15. The edge accepting a hit only sets the read address; the next system edge waits for the synchronous read, the following edge generates a write request, and only the subsequent edge writes through the storage port; a read and write to the same address returns the pre-write value. The screen display is also affected by the pixel read pipeline described below; the hit edge must not be equated with the edge on which the display takes effect.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-4

requirement_ids: R-VRP-004
module: vga_range_plot_top/Busy, Pending Item, and Write Arbitration
definition: dist_vld can still be submitted while distance processing is busy or attenuation is busy; the capacity-one pending item is always overwritten by the latest input. On a system edge when distance processing is idle and attenuation is not busy, an existing pending item is consumed with priority; otherwise, the new item on that edge is consumed. If that edge consumes an old pending item and also has a new item, the new item is not queued again. dist_vld held continuously high is interpreted as an input on every edge.

On each edge, the storage system port first selects the address/write request according to pre-edge state, then updates each processing state. Initialization has highest priority, busy decay has second priority, and distance processing owns the port at all other times. Distance read-modify-write steps that have already started do not pause because decay has just started; their write requests may be lost due to arbitration, so there is no guarantee that every hit is eventually written when the two occur simultaneously. A new sweep_wrap while decay is busy does not start a second decay.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-5

requirement_ids: R-VRP-005
module: vga_range_plot_top/Attenuation Read Pipeline Semantics
definition: Attenuation for this interface is defined by the actual synchronous-port pipeline and must not be understood as atomically decrementing each point in the entire image. The following integer age is used only to define externally observable state changes: after an idle state receives sweep_wrap, it enters age 0 and the address is set to 0; on each subsequent busy edge, the next address is set to max(age−1,0), and age increments; the edge at age 65536 exits busy. When the pre-edge age is greater than 0, a write request and max(pre-edge system read-register value−1,0) are generated for the next edge; otherwise, no write request is generated.

On every edge, the system read register value is updated to the pre-write storage value at the pre-edge selected address; if there is a write request on that edge, the pre-edge write data is written to that selected address. The system port uses the decay address while busy and the distance address while idle. The final decay write request after the busy state ends no longer owns the port, so its commitment is not guaranteed. This recurrence applies equally to histories with zero, sparse, or saturated intensity and histories overlapping distance inputs; it must not be replaced by an ideal scan in which addresses and data are inherently aligned.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-6

requirement_ids: R-VRP-006
module: vga_range_plot_top/Display Window and Intensity Read Latency
definition: The plotting area is defined by pre-edge hcount=0～319 and vcount=120～375; the screen horizontal coordinate maps to x=floor(4hcount/5), y=vcount−120. On each pixel edge, the four-bit read value is synchronously obtained first from the pre-edge read address, while the current mapped address is registered for the next edge; outside the window, address 0 is registered. RGB uses the pre-edge synchronous read value. Thus, color geometry is based on the current pre-edge scan coordinates, while intensity passes through three stages—address register, memory read, and color register—and this relationship also holds at the boundaries. If a system-port write and a pixel read occur at the same simulation time, the pixel read obtains the pre-write value.

When pre-edge active_video is false, RGB is 000; the active region defaults to black. In the drawing region, RGB is 333 when there is no intensity and 0I0 for nonzero intensity I. Display values hold between pixel edges. The logo region is at hcount=0–159, vcount=0–119 and takes logo_rgb from that edge; this region does not overlap the drawing region.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-7

requirement_ids: R-VRP-007
module: vga_range_plot_top/Rings, Axes, and Indicator Block
definition: The three horizontal rings are calculated at one, two, and three times the distance floor(R_MAX_MM/4), using the floor-rounded value floor(distance×255/R_MAX_MM), with no half-range rounding term for a distance hit; the ratio is zero when R_MAX_MM=0. The screen vertical coordinate of a ring is 375−ratio, with color 088 inside the plotting area. The plotting area's bottom edge, vcount=375, or current mapped x=0 is white fff, overriding rings and intensity.

The logo indicator block covers hcount=150–159, vcount=0–7 and is actually 10×8; logo_buf_sel=0 displays f00, and a value of 1 displays 0f0, taking priority over logo_rgb. The indicator block is not displayed outside the window. All colors use the pre-edge scan position and the inputs at that edge; bank changes are not required to occur at frame boundaries.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-8

requirement_ids: R-VRP-008
module: vga_range_plot_top/Logo Coordinates
definition: On a pixel edge within the logo area, logo_x registers 2hcount and logo_y registers 2vcount; outside the area, zero is registered. Coordinates and RGB are both stable after that pixel edge and use the pre-edge position. External logo_rgb is a direct input to this module; it is not generated internally by this module based on coordinates, and there is no request/response handshake. System-domain inputs change on the system falling edge and are held across the rising edge; logo inputs should also avoid competing with the pixel rising edge. Do not perform any reads or writes to internal scan state or storage.
interface: active_video, clk_100mhz, dist_mm, dist_vld, frame_tick, hcount, logo_buf_sel, logo_rgb, logo_x, logo_y, pix_clk, rgb_plot, rst_sys, sweep_wrap, theta_q15, vcount, vga_hsync_n, vga_vsync_n
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.
