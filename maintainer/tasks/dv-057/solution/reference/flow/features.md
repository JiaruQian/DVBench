### F-1

requirement_ids: R-MCNN-001
module: CNN/Interface, Initialization, and Sampling
definition: The clk period is 10 ns; rst_b is active low and asynchronously resets control and arithmetic register state. At startup, rst_b=0 and en=0 must be maintained for at least two complete clock cycles to allow fixed parameter storage to finish initialization, then reset must be deasserted on a falling edge. mem is an ascending packed vector [0:2399], representing 30×10 signed eight-bit pixels in row-major order; pixel (row,col) occupies mem[(row×10+col)×8 +:8], with range −128–127, and there is no input floating-point conversion. All inputs are driven on falling edges, and outputs are sampled after they stabilize following rising edges. valid is zero during reset; when valid=0, no numerical guarantees are made for the floating-point data, including old outputs during reset.
interface: clk, en, float_out0, float_out1, mem, rst_b, valid
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-2

requirement_ids: R-MCNN-002
module: CNN/Image Capture and Input History
definition: Starting from reset release, count rising edges with en=1; non-enabled edges do not increment this count. Every 288th enabled edge atomically captures mem at that edge. Changes to mem at other times do not affect image storage; mem may change every cycle. Reset clears the previously captured image to all zeros. Continuous operation has no per-frame ready or acceptance signal.

Each capture edge produces one eventual pending output result, using the previously captured image A and the current image B. The main computation is the network below applied to A, with an exception for depthwise convolution input channel 31 corresponding to pooling position 8: its convolution patches for depthwise convolution rows 16 and 17 are computed from B. All other depthwise convolution rows/channels come from A; in particular, position 7 still uses A, and position 7 must not be changed as a side effect of first replacing the last four rows of the entire convolution tensor. For the first capture, A is the reset zero image. This boundary mixing is part of this task's definition and naturally reduces to the complete mathematical network when the same image is held; transition outputs must not be ignored.
interface: clk, en, float_out0, float_out1, mem, rst_b, valid
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-3

requirement_ids: R-MCNN-003
module: CNN/First-layer convolution and fixed-point activation
definition: Conv_Weight is ordered by output channel, kernel row, and kernel column, 32×11×7; Conv_Bias has one entry per channel. The image uses no padding and stride one, producing 20×4 values per channel: the bias plus the sum of the corresponding 11×7 signed products. Fixed-point activation is defined as first multiplying the sum by the given multiplier and truncating to signed 32 bits, then arithmetically right-shifting by the given number of bits, and finally clamping to 0–127; no rounding. The first-layer multiplier is 111 and the shift is 14. All accumulation and multiplication retain the low 32 bits. Pixels and weights are interpreted as eight-bit two's complement, and biases as signed 32-bit values. Integers in the parameter files are the corresponding signed values.
interface: clk, en, float_out0, float_out1, mem, rst_b, valid
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-4

requirement_ids: R-MCNN-004
module: CNN/Depthwise convolution, pointwise convolution, and pooling
definition: DWConv_Weight is ordered by input channel, then 3×3 kernel row/column; DWConv_Bias has one entry per channel. Apply an unpadded 3×3 convolution with stride one to each channel's first-layer 20×4 array, obtaining 18×2; the activation multiplier is 59 and the shift is 11. Only the channels/rows specified by R-MCNN-002 use B's first-layer convolution patches.

PWConv_Weight is ordered by output channel and input channel, 32×32; PWConv_Bias has one entry per output channel. At each spatial point, sum the products over 32 input channels and add the bias, with activation multiplier 69 and shift 13, producing 32×18×2. Non-overlapping 2×2 max pooling forms nine values per channel; positions p=0–8 use rows 2p and 2p+1 and two columns. All pooled values are nonnegative eight-bit values, and the flattened index is channel×9+p. A position-first weight flattening order must not be used.
interface: clk, en, float_out0, float_out1, mem, rst_b, valid
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-5

requirement_ids: R-MCNN-005
module: CNN/Fully connected layer, truncation, and table lookup
definition: Linear_Weight is ordered by output class and flattened index, 2×288; Linear_Bias has one entry per class. Each class logit is the bias plus the sum of products of 288 pooled values and their corresponding signed weights, retaining signed 32 bits. Multiply the logit by 11, truncate to 32 bits, arithmetically right-shift by 15, and then retain only the low eight bits as the LUT address. These eight bits use truncation wraparound, with no additional saturation: for example, even if the arithmetic right-shift result is outside −128–127, the low eight bits are still taken. The 256 entries in sigmoid_lookup_table.txt are ordered by unsigned eight-bit address, with positive-value addresses first and negative-value addresses afterward according to their two's-complement bit patterns; float_out0/1 must match the corresponding 32-bit hexadecimal data bit for bit.
interface: clk, en, float_out0, float_out1, mem, rst_b, valid
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-6

requirement_ids: R-MCNN-006
module: CNN/Latency, valid, and pauses
definition: On the 51th enabled rising edge after the capture edge, output the corresponding result and set valid to one; on other enabled edges, set valid to zero. Thus, the first valid occurs on the 339th enabled edge, with subsequent occurrences separated by 288 enabled edges. When en=0, control, the arithmetic pipeline, and valid hold; if paused when valid=1, valid remains one and its valid data holds, and must not be pulsed again according to wall-clock cycles. The output LUT read enable comes from its final-stage index and is not further ANDed with en: when paused at the boundary where the final-stage final index is ready but valid has not yet been set to one, the data bits may update before valid, but no numerical value is guaranteed when valid=0. The value, order, and enabled-edge latency of the first valid result after a pause must be preserved.
interface: clk, en, float_out0, float_out1, mem, rst_b, valid
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.

### F-7

requirement_ids: R-MCNN-007
module: CNN/Repetition, reset recovery, and fixed data
definition: Arbitrary consecutive image captures, repeated images, full-range signed pixels, arbitrary finite pauses, and resets during operation are all legal. Reset discards unfinished results, restarts the enabled-edge count, and restores A to the zero image; fixed weights/biases/LUT do not change with reset, en, or mem. Initialization preparation must be satisfied again after a reset during operation. A stable image must undergo history propagation, and its first valid window is still calculated according to the explicit A/B relationship. CNN has no runtime parameter-loading port; the candidate must not change fixed data or read internal SRAM. Values defined by the publicly provided attachment data may be used as independent-model constants or through authorized data reads.
interface: clk, en, float_out0, float_out1, mem, rst_b, valid
timing: This item samples using the clock-edge and pre-edge/post-edge relationships defined in natural language; the priority of pause and reset follows the explicit conditions in this item.
boundary: The covered objects and legal boundaries for this item are governed by the complete conditions in definition; do not additionally assume undeclared handshakes or internal visibility.
