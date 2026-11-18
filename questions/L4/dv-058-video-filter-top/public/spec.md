# video_filter_top behavioral specification

Covers only the native top level and fixed parameter combination declared in ports.md. All inputs satisfy the stability time at their sampling edges; no hidden hierarchical access.

### R-dv-058-001 — Fixed interface and parameter ranges

For this task, the complete video_filter_top and all dependencies have fixed DATA_WIDTH=24, IMAGE_WIDTH=384, IMAGE_HEIGHT=64, BLINK_RATE=6, DEBOUNCE_LIMIT=2500000. RGB is R[23:16],G[15:8],B[7:0]. All inputs are stable before the rising edge of clk; there is no ready/backpressure. btn[3:2] has no effect. IMAGE_HEIGHT does not limit the text y counter; the top-level DEBOUNCE_LIMIT does not change the fixed 2500000 sampling limit in each submodule.

All sequential state updates only on the rising edge of clk, and outputs settle after the edge. sw/btn may change on every edge; there is no frame latching.

Only the fixed profile above; all inputs are known two-state values and satisfy setup and hold times; unsupported parameter configurations are not required.

### R-dv-058-002 — Synchronous active-low reset and recovery

n_rst low clears the top-level data/control/LEDs, filter outputs, window registers and pointers, text coordinates, and blink count and enable only on a rising edge; the threshold returns to 128, Gaussian mode to 1, Sobel mode to 0, and button counts/prev are cleared to 0. RAM contents are retained.

Pulling n_rst low between edges does not immediately change outputs; after the reset rising edge, all outputs are 0; after release, the native pipeline resumes.

RAM is not initialized by reset; data from the first read of an unwritten slot is unspecified and must not be assumed to be 0.

### R-dv-058-003 — Eight-way real-time selection and retained history

sw[2:0] selects, in order, 0 original, 1 grayscale, 2 negative, 3 threshold, 4 Gaussian, 5 sharpen, 6 Sobel, 7 emboss. The seven filters run in parallel, and unselected paths still retain and update their states. Changes to sw do not wait for a frame boundary.

Data and control are selected combinationally; the top level and text have different latencies, and values are taken according to their respective histories when switching.

The 8 paths must not be misinterpreted as paths with a uniform latency; history of unselected paths must not be cleared.

### R-dv-058-004 — Grayscale, negative, and threshold pixel arithmetic

Y=floor((77R+150G+29B)/256). Grayscale outputs (Y,Y,Y); negative is 255-input for each channel; threshold outputs white when Y>=the pre-edge threshold, otherwise black. Data and input control are registered on every non-reset edge; computation also occurs when VDE is low.

These filter registers update first, then the text and final registers form the output; the old threshold is still used on the edge when the threshold changes.

RGB 0/255, Y equal to threshold is white; blanking data also participates in computation.

### R-dv-058-005 — Button sampling, threshold saturation, and priority

The threshold/Gaussian/Sobel free-running 22-bit counters increment from 0 on every edge, clear to 0 when the pre-edge value is 2500000, and sample the routed buttons, thus once every 2500001 non-reset edges. Only a sampled low-to-high transition triggers; a long press does not repeat; threshold btn0 adds 5 and btn1 subtracts 5, clamped to 0..255; simultaneous new rising transitions give increment priority, and both prev values are updated. Only sw3 routes to threshold, sw4/6 route to their respective btn0, and other routing is 0.

The count does not restart based on the button level; an unsampled release does not form a new visible low state. Data on the update edge uses the old threshold.

Narrow pulses may be missed by sampling; top-level parameters cannot accelerate sampling; btn2/3 and btn1 for Gaussian/Sobel have no effect.

### R-dv-058-006 — Three Gaussian modes

For each RGB channel, compute the weighted sum of the four corners with kc, the four edges with ke, and the center with km from the old 3x3 window, then perform integer division by D. Mode 0=(1,1,2,10), 1=(1,2,4,16), 2=(1,3,9,25). Reset to mode 1; sampled btn0 rising edges cycle through 1→2→0→1.

Use the pre-edge window and mode to compute the filter register value for this edge, then pass it through the text and top-level registers.

Uninitialized window data is unspecified; VDE only gates the window, and the output registers compute on every edge.

### R-dv-058-007 — Signed saturation for sharpen

For each channel, compute 5*p11-p01-p10-p12-p21 from the old window; clamp results below 0 to 0 and above 255 to 255, and otherwise take 8 bits.

Compute from the old window and register the result on the rising edge; the text and top level continue to retain their respective register delays.

The signed 12-bit range is sufficient to cover legal pixels; do not treat this as unsigned underflow.

### R-dv-058-008 — Sobel directions and three modes

First compute Y. For the old grayscale window, Gx=-p00+p02-2p10+2p12-p20+p22, Gy=-p00-2p01-p02+p20+2p21+p22. Mode 0 takes abs(Gx)+abs(Gy), 1 takes abs(Gx), and 2 takes abs(Gy); all are clamped to 0..255 and replicated across RGB. Reset to mode 0; newly sampled btn0 rising edges cycle through 0→1→2→0.

The window advances only when VDE is high; the filter output is computed from the old window/old mode on every edge.

The directional signs, absolute values, and total magnitude are independent; cap the maximum at 255.

### R-dv-058-009 — Actual emboss convolution

Compute -2*p00-p01-p10+p11+p12+p21+2*p22+128 from the old grayscale window, clamp to 0..255, and replicate across RGB. The coefficient sum is 1; a constant window q yields min(q+128,255).

On every non-reset edge, register the result from the old window before entering the common text/output path.

Do not replace the actual formula with the source-code comment stating that flat regions are approximately 128.

### R-dv-058-010 — VDE-gated RAM windows and non-ideal geometry

The two RAMs of W=384 in each window read the old mem[ptr] and write the new input to the same address on edges where VDE is high; ptr returns to 0 at W-1. lb2 writes the old lb1 output; on the same edge, p22 takes the input, p12 takes the old lb1 output, and p02 takes the old lb2 output, with each row shifting horizontally. Valid pixels u[k] correspond to p22=u[k],p21=u[k-1],p20=u[k-2],p12=u[k-W-1],p11=u[k-W-2],p10=u[k-W-3],p02=u[k-2W-2],p01=u[k-2W-3],p00=u[k-2W-4], valid only after the respective slots have been written.

When VDE is low, the RAMs, pointers, windows, and line buffer outputs hold; hsync/vsync do not flush them. Filter outputs are computed from the old window on every edge.

Reset clears only the pointers, lb outputs, and windows; RAM is retained. Values in initially unwritten slots are unspecified. There is no padding, clearing of horizontal shifts at line ends, or frame flush.

### R-dv-058-011 — Text coordinates, names, and glyph bitmaps

Text x increments by 1 on edges where raw VDE is high, returns to 0 at 383, and clears to 0 when VDE is low. y clears to 0 on a raw vsync falling edge, taking priority over incrementing by 1 on a VDE falling edge, and wraps naturally at 11 bits. The box is x∈[16,383],y<48; the nine-character area contains, in order, NORMAL, GREYSCALE, NEGATIVE, THRESHOLD, GAUSSIAN, SHARPEN, SOBEL, EMBOSS, padded with spaces as needed. SCALE=5,PAD=4, tx=x-20, ty=y-4, computed with 11-bit coordinates; in_text additionally requires x/y>=4 within the box, tx<360, and ty<40; the character index is tx/40, the column within the character is (tx%40)/5, and the row is ty/5, selecting row bitmap[7-col]. Strokes are white, the remainder inside the box is black, and outside the box the selected pixel is used. The 8 rows of each character, from top to bottom, are hex bitmaps: A:3C/66/66/7E/66/66/66/00; B:7C/66/66/7C/66/66/7C/00; C:3C/66/60/60/60/66/3C/00; D:78/6C/66/66/66/6C/78/00; E:7E/60/60/7C/60/60/7E/00; G:3C/66/60/6E/66/66/3C/00; H:66/66/66/7E/66/66/66/00; I:3C/18/18/18/18/18/3C/00; L:60/60/60/60/60/60/7E/00; M:42/66/7E/5A/42/42/42/00; N:66/76/7E/6E/66/66/66/00; O:3C/66/66/66/66/66/3C/00; P:7C/66/66/7C/60/60/60/00; R:7C/66/66/7C/6C/66/66/00; S:3C/66/60/3C/06/66/3C/00; T:7E/18/18/18/18/18/18/00; U:66/66/66/66/66/66/3C/00; V:66/66/66/66/66/3C/18/00; Y:66/66/66/3C/18/18/18/00; all other characters are all 0.

Text is registered on every edge, without VDE gating the data; coordinates and the selected pixel use pre-edge values. Synchronization controls do not pass through the text layer.

hsync does not participate in the coordinates, and IMAGE_HEIGHT64 does not limit y either; the text is actually in the upper-right corner; low VDE does not prohibit black background box output.

### R-dv-058-012 — Split screen and data/control latency

The independent top-level x updates according to raw VDE. When sw3=1, pre-edge x∈[191,193] has priority and outputs a white divider; otherwise, x>=192 outputs old text data, and the left side outputs the current input; when sw3=0, all output uses old text data. Controls always register the pre-edge selected controls. Outside the box in a stable mode, after edge n the raw path has data=P[n-1] while control=H[n]; single-pixel filtering has data=F(P[n-2]) while control=H[n-1].

Top-level split-screen x, overlay coordinates, and data use their respective pre-edge states; no additional output alignment is guaranteed.

Do not assume that the left/right sides correspond to the same pixel cycle or that VDE and RGB are aligned; calculate window paths separately according to their recurrences.

### R-dv-058-013 — LED blinking and old phase

When the pre-edge 26-bit blink count is >=6, clear it to 0 and toggle enable; otherwise increment it by 1. The LED uses the old enable on the same edge, and reflects the toggle only on the next edge; when on, sw[1:0]=0/1/2/3 corresponds to 0001/0010/0100/1000; when off, it is 0000, the same for both filter categories.

The toggle interval is 7 non-reset edges, and a complete on/off cycle is 14 edges; reset clears the count, enable, and LED.

A mode change alters the one-hot selection in real time, but must not use the new enable early.

