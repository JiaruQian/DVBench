# fft_wrapper Behavioral Specification

The fixed parameters are DIVISOR=5, N=16, Q=8, ADDR_WIDTH=5, DATA_WIDTH=16, DEPTH=32.

### R-dv-055-001 — Input RAM Writes

When `m_we` is 1 on the rising edge of `clk`, `m_data` is written to the input RAM word specified by `m_addr`. Input RAM is not initialized by reset; required samples must be written through the ports before reading.

### R-dv-055-003 — Continuous Operation

The internal FFT core runs freely with the external clock, and the interface has no start, ready, or done handshake. `rst` is an asynchronous active-high reset; input and output RAM contents are not initialized by reset.

### R-dv-055-002 — Output RAM Reads

When `s_re` is asserted, the output RAM samples `s_addr` on the rising edge of `clk` and updates `s_data` after that edge. When `s_re=0`, `s_data` holds the previous read value; `rst` does not clear this output register. If reading remains enabled during reset, the read value is not guaranteed to be zero. `s_data[31:16]` is the real-part word, and `s_data[15:0]` is the imaginary-part word.

### R-dv-055-004 — Full-Frame Numerical Results and Stable Window

When verifying a frame, first write each address from 0 to 31 once on clock edges of `m_we=1`; the write order may vary. After the last write, keep the input RAM unchanged for at least 20 rising edges of `clk`, then read the results through `s_re`. Within this stable window, the 32 complex outputs are arranged in natural frequency order and equal the 32-point forward fixed-point FFT below. Partial frames, outputs before the first valid window, and intermediate outputs during continuous writes are outside the checking domain of this clause. After reset, rewrite a complete frame and wait for the same 20-edge stable window before checking numerical results; when reading is disabled during reset, the output register continues to hold the previous read value.

Each input and real/imaginary result is a 16-bit two's-complement Q8.8 value. Let `bitrev5(i)` be the 5-bit reversal of i, and let the initial vector be `v[i] = {x[bitrev5(i)], 0}`. For stage `s=0..4`, let `L=2^(s+1)`; for each starting point `base` (taking `0,L,2L,...,32-L`) and `j=0..L/2-1`, the two inputs are `a=v[base+j]` and `b=v[base+j+L/2]`, and the twiddle index is `k=j*(32/L)`. In coefficient table `k=0..15`, `C[k]` and `S[k]` represent the real part and sine magnitude, respectively; the table values are exact 16-bit two's-complement words:

| k | C[k] | S[k] |
|---:|---:|---:|
|0|0100|0000|
|1|00FB|0031|
|2|00EC|0062|
|3|00D4|008E|
|4|00B4|00B4|
|5|008E|00D4|
|6|0062|00EC|
|7|0031|00FB|
|8|0000|0100|
|9|FFCF|00FB|
|10|FF9E|00EC|
|11|FF72|00D4|
|12|FF4C|00B4|
|13|FF2C|008E|
|14|FF14|0062|
|15|FF05|0031|

`qmul(p,q)` first computes the product of the absolute values according to the signs, then takes `floor(abs(p*q)/256)`, and finally restores the product's sign; each multiplication is truncated independently, without rounding. Let `t_r=qmul(b_r,C[k])+qmul(b_i,S[k])` and `t_i=qmul(b_i,C[k])-qmul(b_r,S[k])`. The two results of this stage are `a+(t_r,t_i)` and `a-(t_r,t_i)`; each addition and subtraction wraps around in 16-bit two's complement, without saturation. After all five stages are complete, the upper 16 bits of output `i` are the real part, and the lower 16 bits are the imaginary part.
