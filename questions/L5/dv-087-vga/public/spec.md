# VGA Distance Intensity Map

The target of this task is the complete `vga_range_plot_top`: system clock, pixel clock, scanning, dual-port 256×256 four-bit intensity storage, distance accumulation, scan decay, layers, and logo interface. All vectors are unsigned; temperature parameters are signed. See ports.md for the complete interface. The legal parameter domain of R_MAX_MM is 0–65535, with default 2000; neither temperature parameter affects outputs anywhere in the entire signed 16-bit domain.

### R-VRP-001 — Clocks, Reset, and Startup Clearing

The period of clk_100mhz is 10 ns. rst_sys is active high: system state resets on the rising edge; the divider reset request is asynchronously asserted into a two-stage synchronizer, which shifts in zero on every system edge after deassertion, and clock division uses the pre-edge second stage. The divider's internal half-count and pix_clk are set to zero on reset; after release, the half-count alternates between 0 and 1, toggling pix_clk only when the pre-edge half-count is 1, so the pixel clock is 25 MHz. The pixel reset request is also asynchronously asserted into a two-stage synchronizer, which shifts in zero on every pixel rising edge; all pixel state uses the pre-edge second stage. The pixel clock stops during reset, and pixel registers must not be assumed to clear asynchronously; only reset pixel edges after resumption clear scanning, coordinates, and RGB to zero and set synchronization signals high.

Every system edge with rst_sys high restarts initialization, with the clear address starting at 0; after deassertion, all 65536 addresses are cleared sequentially, and initialization exits on the same edge that clears the final address. Initialization takes priority over all other storage accesses; distance and decay state remain in reset, and hits cannot be accepted. Legal functional inputs must wait at least 65550 system cycles after deassertion. Scanning proceeds independently; stored read values are displayed only after initialization completion has been synchronized through two pixel edges, and intensity is treated as zero before then. Reset may be reapplied during operation, and clearing must be completed again.

### R-VRP-002 — Full Scan and Synchronization

Normal pixel edges use pre-edge counts to produce registered outputs, then advance the counts: hcount runs from 0 to 799, incrementing vcount when it returns to zero, and vcount runs from 0 to 524 before returning to zero. active_video is the combinational result of current hcount<640 and vcount<480; frame_tick is true when current hcount=0, vcount=0, and active_video is true. vga_hsync_n is low when pre-edge hcount is within 656–751; vga_vsync_n is low when pre-edge vcount is within 490–491. Thus, synchronization signals have a one-cycle relationship to post-edge counts and must not be recomputed combinationally from post-edge counts.

### R-VRP-003 — Intensity Accumulation from Distance and Angle

Each system rising edge with dist_vld high supplies one polar-coordinate input; the low angle bits are not required to be zero. The horizontal coordinate x is the upper eight bits of theta_q15. First clamp dist_mm to R_MAX_MM, let scaled=floor((clamped×255+floor(R_MAX_MM/2))/R_MAX_MM), and set the vertical coordinate y=255-scaled; when R_MAX_MM=0, scaled is fixed at 0. Distance spans the full unsigned 16-bit domain. The linear address is 256y+x.

A hit adds 3 to the old four-bit intensity and saturates at 15. The edge accepting a hit only sets the read address; the next system edge waits for the synchronous read, the following edge generates a write request, and only the subsequent edge writes through the storage port; a read and write to the same address returns the pre-write value. The screen display is also affected by the pixel read pipeline described below; the hit edge must not be equated with the edge on which the display takes effect.

### R-VRP-004 — Busy State, Pending Item, and Write Arbitration

dist_vld may still be submitted while distance processing or decay is busy; the latest input always overwrites the single-entry pending item. On a system edge when distance processing is idle and decay is not busy, an existing pending item is consumed first; otherwise, a new item from that edge is consumed. If that edge both consumes an old pending item and has a new item, the new item is not requeued. Holding dist_vld high continuously is interpreted as an input on every edge.

On each edge, the storage system port first selects the address/write request according to pre-edge state, then updates each processing state. Initialization has highest priority, busy decay has second priority, and distance processing owns the port at all other times. Distance read-modify-write steps that have already started do not pause because decay has just started; their write requests may be lost due to arbitration, so there is no guarantee that every hit is eventually written when the two occur simultaneously. A new sweep_wrap while decay is busy does not start a second decay.

### R-VRP-005 — Decay Read-Pipeline Semantics

Decay in this interface is defined by the actual synchronous-port pipeline and must not be understood as atomically decrementing every point in the entire image by one. The following integer age is used only to define externally observable state changes: receiving sweep_wrap while idle enters age 0 and sets the address to 0; each subsequent busy edge sets the next address to max(age−1,0) and increments the age; the edge at age 65536 exits the busy state. When the pre-edge age is greater than 0, a write request and max(pre-edge system read register value−1,0) are generated for the next edge; otherwise, no write request is generated.

On every edge, the system read register value is updated to the pre-write storage value at the pre-edge selected address; if there is a write request on that edge, the pre-edge write data is written to that selected address. The system port uses the decay address while busy and the distance address while idle. The final decay write request after the busy state ends no longer owns the port, so its commitment is not guaranteed. This recurrence applies equally to histories with zero, sparse, or saturated intensity and histories overlapping distance inputs; it must not be replaced by an ideal scan in which addresses and data are inherently aligned.

### R-VRP-006 — Display Window and Intensity Read Latency

The drawing region is pre-edge hcount=0–319, vcount=120–375; the screen horizontal coordinate maps to x=floor(4hcount/5), y=vcount−120. Each pixel edge first synchronously obtains a four-bit read value from the pre-edge read address, while registering the current mapped address for the next edge; outside the window, address 0 is registered. RGB uses the pre-edge synchronous read value. Thus, color geometry is based on the current pre-edge scan coordinates, whereas intensity passes through three stages: address register, storage read, and color register; this relationship is preserved at boundaries as well. When a system-port write and a pixel read occur at the same simulation time, the pixel read obtains the pre-write value.

When pre-edge active_video is false, RGB is 000; the active region defaults to black. In the drawing region, RGB is 333 when there is no intensity and 0I0 for nonzero intensity I. Display values hold between pixel edges. The logo region is at hcount=0–159, vcount=0–119 and takes logo_rgb from that edge; this region does not overlap the drawing region.

### R-VRP-007 — Ring Lines, Coordinate Axes, and Indicator Block

The three horizontal ring lines are calculated at one, two, and three times the distance floor(R_MAX_MM/4), using downward rounding floor(distance×255/R_MAX_MM), without the half-range rounding term used for distance hits; when R_MAX_MM=0, the scaled value is zero. The ring-line screen vertical coordinate is 375−scaled value, with color 088 inside the drawing region. The bottom edge of the drawing region at vcount=375 or the current mapped x=0 is white fff, overriding ring lines and intensity.

The logo indicator block covers hcount=150–159, vcount=0–7 and is actually 10×8; logo_buf_sel=0 displays f00, and a value of 1 displays 0f0, taking priority over logo_rgb. The indicator block is not displayed outside the window. All colors use the pre-edge scan position and the inputs at that edge; bank changes are not required to occur at frame boundaries.

### R-VRP-008 — Logo Coordinates

On pixel edges inside the logo region, logo_x registers 2hcount and logo_y registers 2vcount; outside the region, they register zero. Coordinates and RGB both stabilize after that pixel edge and use the pre-edge position. External logo_rgb is a direct input to this module, is not generated internally by this module from the coordinates, and has no request/response handshake. System-domain inputs change on system falling edges and remain stable across rising edges; logo inputs should also avoid races with pixel rising edges. No reads or writes to internal scanning or storage are permitted.
